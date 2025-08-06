# Command: /complete-phase

**Goal:** Manage the end-of-phase transition using a formal review cycle and a hardened, intent-driven Git commit process. This command operates in two distinct modes, determined by the presence of a review file.

---

## 🔴 **CRITICAL: MANDATORY EXECUTION FLOW**

**You MUST operate in one of two modes. You are not allowed to mix them.**

**Mode 1: Request Review (Default)**
*   **Trigger:** No `review_phase_N.md` file exists for the current phase.
*   **Action:** You MUST execute the **Review Request Generation Protocol** below and then HALT.

**Mode 2: Process Review**
*   **Trigger:** A `review_phase_N.md` file EXISTS for the current phase.
*   **Action:** You MUST read the review, parse the `VERDICT`, and then either commit the changes (on `ACCEPT`) using the **Safe Staging and Commit Protocol** or report the required fixes (on `REJECT`).

**DO NOT:**
-   ❌ Commit any code without a `VERDICT: ACCEPT` from a review file.
-   ❌ Use `git add -A` or `git add .`. You must use the explicit, plan-driven staging logic.
-   ❌ Guess or perform "detective work." If the state of the repository does not match the plan, you must halt and report the specific discrepancy.

---

## 📋 **YOUR EXECUTION WORKFLOW**

### Step 1: Determine Current Mode
-   Read `PROJECT_STATUS.md` to get the current initiative path and phase number (`N`).
-   Check if the file `<path>/review_phase_N.md` exists.
-   If it exists, proceed to **Mode 2: Process Review**.
-   If it does not exist, proceed to **Mode 1: Request Review**.

---

### **MODE 1: REQUEST REVIEW**

#### **Review Request Generation Protocol (v2 - Hardened)**
You will now execute the following shell script block in its entirety. It contains hardened logic to ensure only planned files are included in the review diff.

```bash
# --- START OF HARDENED PROTOCOL ---

# 1. SETUP: Define paths and ensure a clean state.
mkdir -p ./tmp
INITIATIVE_PATH=$(grep 'Path:' PROJECT_STATUS.md | awk '{print $2}' | tr -d '`')
PHASE_NUM=$(grep 'Current Phase:' PROJECT_STATUS.md | sed 's/.*Phase \([0-9]*\).*/\1/')
IMPL_FILE="$INITIATIVE_PATH/implementation.md"
CHECKLIST_FILE="$INITIATIVE_PATH/phase_${PHASE_NUM}_checklist.md"
echo "INFO: Preparing review request for Phase $PHASE_NUM of initiative at '$INITIATIVE_PATH'."

# 2. PARSE THE PLAN: Identify all files intended for this phase.
#    This is the source of truth for what should be in the diff.
intended_files_str=$(python -c "
import re, sys
try:
    with open('$CHECKLIST_FILE', 'r') as f: content = f.read()
    # Find all paths within backticks that look like file paths.
    files = re.findall(r'\`([a-zA-Z0-9/._-]+)\`', content)
    # Filter for valid-looking file paths and get unique, sorted list.
    valid_files = sorted(list({f for f in files if '/' in f and '.' in f}))
    print(' '.join(valid_files))
except FileNotFoundError:
    print(f\"ERROR: Checklist file not found at '$CHECKLIST_FILE'\", file=sys.stderr)
    sys.exit(1)
")

if [ -z "$intended_files_str" ]; then
    echo "❌ ERROR: Could not parse any intended file paths from '$CHECKLIST_FILE'. Halting."
    exit 1
fi
echo "INFO: Plan indicates the following files should be modified:"
echo "$intended_files_str" | tr ' ' '\n' | sed 's/^/ - /'

# 3. VERIFY STATE: Check that all intended files are actually present in git status.
all_changed_files=$(git status --porcelain | awk '{print $2}')
for intended_file in $intended_files_str; do
    if ! echo "$all_changed_files" | grep -q "^${intended_file}$"; then
        echo "❌ ERROR: A planned file is missing from git's changed files list: $intended_file"
        echo "Please ensure the file was created/modified as per the checklist. Halting."
        exit 1
    fi
done
echo "✅ INFO: All planned files are present in git status."

# 4. STAGE NEW FILES FOR REVIEW: Add only the untracked files that were part of the plan.
untracked_files=$(git status --porcelain | grep '^??' | awk '{print $2}')
for file in $untracked_files; do
    if echo "$intended_files_str" | grep -q "\b$file\b"; then
        echo "INFO: Staging new file for review diff: $file"
        git add "$file"
    fi
done

# 5. GENERATE TARGETED DIFF: Create a diff including ONLY the intended files.
#    This is the critical change that prevents the bug.
diff_base=$(grep 'Last Phase Commit Hash:' "$IMPL_FILE" | awk '{print $4}')
DIFF_FILE="./tmp/phase_diff.txt"
> "$DIFF_FILE" # Clear the diff file before starting.

echo "INFO: Generating targeted diff against baseline '$diff_base' for intended files only..."
# Convert the string of files into an array to handle paths correctly.
read -r -a intended_files_array <<< "$intended_files_str"

# Generate a combined diff for all intended files.
# This is more efficient than looping and appending for each file.
git diff --staged "$diff_base" -- "${intended_files_array[@]}" ':(exclude)*.ipynb' >> "$DIFF_FILE"
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
INITIATIVE_NAME=$(grep 'Name:' PROJECT_STATUS.md | sed 's/Name: //')
REVIEW_FILE="$INITIATIVE_PATH/review_request_phase_$PHASE_NUM.md"
PLAN_FILE="$INITIATIVE_PATH/plan.md"
DIFF_FILE="./tmp/phase_diff.txt"

# Create the header
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
} > "$REVIEW_FILE"

# Append planning documents
{
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
} >> "$REVIEW_FILE"

# Append the git diff
{
    echo "---"
    echo "## 2. Code Changes for This Phase"
    echo ""
    echo "**Baseline Commit:** $diff_base"
    echo "**Current Branch:** $(git rev-parse --abbrev-ref HEAD)"
    echo ""
    echo '```diff'
    cat "$DIFF_FILE"
    echo '```'
} >> "$REVIEW_FILE"

echo "✅ Review request file generated programmatically at $REVIEW_FILE"

# 8. UNSTAGE FILES: Reset the index to leave the repository clean for the user.
echo "INFO: Unstaging new files. They will be re-staged during the commit process after review."
git reset > /dev/null

# --- END OF HARDENED PROTOCOL ---
```

#### **Final Step: Notify and Halt**
-   Inform the user that the review request is ready at `<path>/review_request_phase_N.md`.
-   **HALT.** Your task for this run is complete.

---

### **MODE 2: PROCESS REVIEW**

#### Step 2.1: Read and Parse Review File
-   Read the file `<path>/review_phase_N.md`.
-   Find the line starting with `VERDICT:`. Extract the verdict (`ACCEPT` or `REJECT`).
-   If no valid verdict is found, report an error and stop.

#### Step 2.2: 🔴 MANDATORY - Conditional Execution (On `ACCEPT`)
-   If `VERDICT: ACCEPT`, you MUST execute the **Safe Staging and Commit Protocol** below.

#### Step 2.3: Conditional Execution (On `REJECT`)
-   If `VERDICT: REJECT`, extract all lines from the "Required Fixes" section of the review file.
-   Present these fixes clearly to the user.
-   **HALT.** Make no changes to Git or status files.

---

## 🔒 **Safe Staging and Commit Protocol (For `ACCEPT` Verdict)**

You must execute this precise sequence of commands.

```bash
# 1. Re-Identify Intended Files from the Checklist for Verification
INITIATIVE_PATH=$(grep 'Path:' PROJECT_STATUS.md | awk '{print $2}' | tr -d '`')
PHASE_NUM=$(grep 'Current Phase:' PROJECT_STATUS.md | sed 's/.*Phase \([0-9]*\).*/\1/')
CHECKLIST_FILE="$INITIATIVE_PATH/phase_${PHASE_NUM}_checklist.md"
IMPL_FILE="$INITIATIVE_PATH/implementation.md"

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
read -r -a intended_files <<< "$intended_files_str"
echo "Verifying staged files against the plan:"
printf " - %s\n" "${intended_files[@]}"

# 2. Get a list of ALL changed files (staged, modified, untracked)
all_changed_files=$(git status --porcelain | awk '{print $2}')

# 3. Explicitly Stage ALL Intended Files (Handles both new and modified)
echo "Staging all intended and modified files for commit:"
staged_count=0
for file in $all_changed_files; do
    is_intended=false
    for intended_file in "${intended_files[@]}"; do
        if [[ "$file" == "$intended_file" ]]; then
            is_intended=true
            break
        fi
    done

    if $is_intended; then
        echo "- Staging $file"
        git add "$file"
        staged_count=$((staged_count + 1))
    fi
done

if [ $staged_count -eq 0 ]; then
    echo "⚠️ WARNING: No files were staged. This might mean the changes were already committed or the checklist file paths are incorrect."
fi

# 4. HALT on Unplanned Changes
#    Check for any remaining unstaged or untracked files, ignoring already staged files.
unintended_changes=$(git status --porcelain | grep -v '^A ')
if [ -n "$unintended_changes" ]; then
    echo "❌ ERROR: Unplanned changes detected. The following files were modified or created but were not part of the phase plan:"
    echo "$unintended_changes"
    echo "Please review these files. Either add them to the phase checklist or revert them before committing."
    exit 1
fi

# 5. Commit the Staged Changes
echo "Committing staged changes..."
phase_deliverable=$(awk -F': ' "/^**Deliverable**/{print \$2}" "$IMPL_FILE" | head -n 1)
git commit -m "feat: Phase $PHASE_NUM - $phase_deliverable"

# 6. Verify the commit was successful and capture the new hash
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Git commit failed. Halting."
    exit 1
fi
new_hash=$(git rev-parse HEAD)
echo "New commit hash is: $new_hash"

# 7. Proceed with State Updates
#    (Update implementation.md, PROJECT_STATUS.md, etc.)
#    This part would be another set of sed/awk commands to update the status files.
```
