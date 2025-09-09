#!/bin/bash
set -e
set -o pipefail

# --- START OF ENHANCED PROTOCOL ---

# Function to report errors and exit.
fail() {
    echo "❌ ERROR: $1" >&2
    exit 1
}

# 1. ROBUST PARSING: Find the *active* initiative and get its details.
# This awk script ensures we only parse the block for the current initiative.
read INITIATIVE_PATH PHASE_NUM < <(awk '
  /^### / { in_active = 0 }
  /^### Current Active Initiative/ { in_active = 1 }
  in_active && /^Path:/ { path = $2; gsub(/`/, "", path) }
  in_active && /^Current Phase:/ { phase = $3; sub(":", "", phase) }
  END { if (path && phase) print path, phase }
' PROJECT_STATUS.md)

[ -z "$INITIATIVE_PATH" ] && fail "Could not parse INITIATIVE_PATH from PROJECT_STATUS.md."
[ -z "$PHASE_NUM" ] && fail "Could not parse PHASE_NUM from PROJECT_STATUS.md."

echo "INFO: Preparing review for Phase $PHASE_NUM of initiative at '$INITIATIVE_PATH'."

# Define key file paths
IMPL_FILE="$INITIATIVE_PATH/implementation.md"
CHECKLIST_FILE="$INITIATIVE_PATH/phase_${PHASE_NUM}_checklist.md"
[ ! -f "$IMPL_FILE" ] && fail "Implementation file not found at '$IMPL_FILE'."
[ ! -f "$CHECKLIST_FILE" ] && fail "Checklist file not found at '$CHECKLIST_FILE'."

# 2. PARSE THE PLAN: Identify all files intended for this phase.
# This is the source of truth for what should be in the diff.
intended_files_str=$(python -c "
import re, sys
try:
    with open('$CHECKLIST_FILE', 'r') as f: content = f.read()
    files = re.findall(r'\`([a-zA-Z0-9/._-]+)\`', content)
    valid_files = sorted(list({f for f in files if '/' in f and '.' in f}))
    print(' '.join(valid_files))
except FileNotFoundError:
    sys.exit(1)
")
[ -z "$intended_files_str" ] && fail "Could not parse any intended file paths from '$CHECKLIST_FILE'."
echo "INFO: Plan indicates the following files should be modified:"
echo "$intended_files_str" | tr ' ' '\n' | sed 's/^/ - /'
read -r -a intended_files_array <<< "$intended_files_str"

# 3. FAST & TARGETED VERIFICATION: Check that all intended files are present in git status.
# By passing the file list to git status, we avoid scanning the entire repo,
# which prevents timeouts from large, untracked files.
all_changed_planned_files=$(git status --porcelain -- "${intended_files_array[@]}" | awk '{print $2}')
for intended_file in "${intended_files_array[@]}"; do
    if ! echo "$all_changed_planned_files" | grep -q "^${intended_file}$"; then
        fail "A planned file is missing from git's changed files list: $intended_file. Please ensure it was created/modified as per the checklist."
    fi
done
echo "✅ INFO: All planned files are present in git status."

# 4. STAGE NEW FILES FOR REVIEW: Add only the untracked files that were part of the plan.
untracked_files=$(git status --porcelain -- "${intended_files_array[@]}" | grep '^??' | awk '{print $2}' || true)
if [ -n "$untracked_files" ]; then
    for file in $untracked_files; do
        echo "INFO: Staging new planned file for review diff: $file"
        git add "$file"
    done
fi

# 5. GENERATE TARGETED DIFF: Create a diff including ONLY the intended files.
# This is the critical step that prevents large, unplanned files from corrupting the review.
mkdir -p ./tmp
DIFF_FILE="./tmp/phase_diff.txt"
diff_base=$(grep 'Last Phase Commit Hash:' "$IMPL_FILE" | awk '{print $4}')
[ -z "$diff_base" ] && fail "Could not find 'Last Phase Commit Hash:' in $IMPL_FILE."

echo "INFO: Generating targeted diff against baseline '$diff_base' for intended files only..."
# Generate a combined diff for all intended files, excluding notebooks.
git diff --staged "$diff_base" -- "${intended_files_array[@]}" ':(exclude)*.ipynb' > "$DIFF_FILE"
git diff HEAD -- "${intended_files_array[@]}" ':(exclude)*.ipynb' >> "$DIFF_FILE"
echo "INFO: Targeted diff generated."

# 6. SANITY CHECK: Verify the diff is not excessively large.
diff_lines=$(wc -l < "$DIFF_FILE")
MAX_DIFF_LINES=5000 # Set a reasonable limit
if [ "$diff_lines" -gt "$MAX_DIFF_LINES" ]; then
    echo "⚠️ WARNING: The generated diff is very large ($diff_lines lines)."
    echo "This may indicate that a data file or unintended large file was included in the plan."
    echo "Please double-check the file list in '$CHECKLIST_FILE'."
    # This is a warning, not an error, to allow for legitimate large changes.
fi

# 7. GENERATE REVIEW FILE: Programmatically build the review request.
PHASE_NAME=$(awk -F': ' "/### \\*\\*Phase $PHASE_NUM:/{print \$2}" "$IMPL_FILE" | head -n 1)
INITIATIVE_NAME=$(grep 'Name:' PROJECT_STATUS.md | head -n 1 | sed 's/Name: //')
REVIEW_FILE="$INITIATIVE_PATH/review_request_phase_$PHASE_NUM.md"
PLAN_FILE="$INITIATIVE_PATH/plan.md"

# Create the review file from components
{
    echo "# Review Request: Phase $PHASE_NUM - $PHASE_NAME"
    echo ""
    echo "**Initiative:** $INITIATIVE_NAME"
    echo "**Generated:** $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "## Instructions for Reviewer"
    echo "1.  Analyze the planning documents and the code changes (\`git diff\`) below."
    echo "2.  Create a new file named \`review_phase_${PHASE_NUM}.md\` in this same directory (\`$INITIATIVE_PATH/\`)."
    echo "3.  In your review file, you **MUST** provide a clear verdict on a single line: \`VERDICT: ACCEPT\` or \`VERDICT: REJECT\`."
    echo "4.  If rejecting, you **MUST** provide a list of specific, actionable fixes under a \"Required Fixes\" heading."
    echo ""
    echo "---"
    echo "## 1. Planning Documents"
    echo ""
    echo "### R&D Plan (\`plan.md\`)"
    echo '```markdown'
    cat "$PLAN_FILE"
    echo '```'
    echo ""
    echo "### Implementation Plan (\`implementation.md\`)"
    echo '```markdown'
    cat "$IMPL_FILE"
    echo '```'
    echo ""
    echo "### Phase Checklist (\`phase_${PHASE_NUM}_checklist.md\`)"
    echo '```markdown'
    cat "$CHECKLIST_FILE"
    echo '```'
    echo ""
    echo "---"
    echo "## 2. Code Changes for This Phase"
    echo ""
    echo "**Baseline Commit:** $diff_base"
    echo ""
    echo '```diff'
    cat "$DIFF_FILE"
    echo '```'
} > "$REVIEW_FILE"

echo "✅ Review request file generated at: $REVIEW_FILE"

# 8. UNSTAGE FILES: Reset the index to leave the repository clean for the user.
if [ -n "$untracked_files" ]; then
    echo "INFO: Unstaging new files. They will be re-staged during the commit process after review."
    git reset > /dev/null
fi

# --- END OF ENHANCED PROTOCOL ---
