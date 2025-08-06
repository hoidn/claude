# Command: /complete-phase

**Goal:** Manage the end-of-phase transition using a formal review cycle and a hardened, intent-driven Git commit process. This command operates in two distinct modes, determined by the presence of a review file.

---

## 🔴 **CRITICAL: MANDATORY EXECUTION FLOW**

**You MUST operate in one of two modes. You are not allowed to mix them.**

**Mode 1: Request Review (Default)**
*   **Trigger:** No `review_phase_N.md` file exists for the current phase.
*   **Action:** You MUST identify intended new files from the checklist, stage them, generate a comprehensive `git diff`, and then create the `review_request_phase_N.md` file before HALTING.

**Mode 2: Process Review**
*   **Trigger:** A `review_phase_N.md` file EXISTS for the current phase.
*   **Action:** You MUST read the review, parse the `VERDICT`, and then either commit the changes (on `ACCEPT`) using the **safe staging protocol** or report the required fixes (on `REJECT`).

**DO NOT:**
-   ❌ Commit any code without a `VERDICT: ACCEPT` from a review file.
-   ❌ Use `git add -A` or `git add .` at any point. You must use the explicit, plan-driven staging logic.
-   ❌ Proceed with a commit if unplanned file changes are detected. You must halt and report the error.

---

## 🤖 **CONTEXT: YOU ARE CLAUDE CODE**

You are Claude Code, an autonomous agent. You will execute the Git and file commands below to manage the phase completion and review process. You will handle all steps without human intervention.

---

## 📋 **YOUR EXECUTION WORKFLOW**

### Step 1: Determine Current Mode
-   Read `PROJECT_STATUS.md` to get the current initiative path and phase number (`N`).
-   Check if the file `<path>/review_phase_N.md` exists.
-   If it exists, proceed to **Mode 2: Process Review**.
-   If it does not exist, proceed to **Mode 1: Request Review**.

---

### **MODE 1: REQUEST REVIEW**

#### Step 1.1: Read State and Identify Intended Files
-   Read `PROJECT_STATUS.md` to get the initiative path and phase number.
-   Parse the phase checklist to identify all files that were planned to be created or modified.

```bash
# Ensure a temporary directory exists
mkdir -p ./tmp

# Extract initiative path and phase number from PROJECT_STATUS.md
INITIATIVE_PATH=$(grep 'Path:' PROJECT_STATUS.md | awk '{print $2}' | tr -d '`')
PHASE_NUM=$(grep 'Current Phase:' PROJECT_STATUS.md | sed 's/.*Phase \([0-9]*\).*/\1/')
IMPL_FILE="$INITIATIVE_PATH/implementation.md"
CHECKLIST_FILE="$INITIATIVE_PATH/phase_${PHASE_NUM}_checklist.md"

# Identify all files mentioned in the checklist for this phase
intended_files_str=$(python -c "
import re
import sys
try:
    with open('$CHECKLIST_FILE', 'r') as f:
        content = f.read()
    # Find all file paths enclosed in backticks
    files = re.findall(r'\\\`([a-zA-Z0-9/._-]+)\\\`', content)
    valid_files = {f for f in files if '/' in f and '.' in f}
    print(' '.join(sorted(list(valid_files))))
except FileNotFoundError:
    sys.exit(1)
")

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Could not parse the phase checklist '$CHECKLIST_FILE' to determine which files to review."
    exit 1
fi

read -r -a intended_files <<< "$intended_files_str"
echo "Plan indicates the following files should be created or modified:"
printf " - %s\n" "${intended_files[@]}"
```

#### Step 1.2: Stage Intended *New* Files for Review
-   Stage only the new files that were part of the plan, so their content appears in the diff.

```bash
# Get a list of all untracked files
untracked_files=$(git status --porcelain | grep '^??' | awk '{print $2}')

# Stage only the untracked files that were part of the plan
for file in $untracked_files; do
    is_intended=false
    for intended_file in "${intended_files[@]}"; do
        if [[ "$file" == "$intended_file" ]]; then
            is_intended=true
            break
        fi
    done

    if $is_intended; then
        echo "Staging new file for review diff: $file"
        git add "$file"
    fi
done
```

#### Step 1.3: Generate Comprehensive Diff
-   Generate a diff that now includes both modified tracked files and the full content of the newly staged files.

```bash
# Extract the baseline commit hash for the diff
diff_base=$(grep 'Last Phase Commit Hash:' "$IMPL_FILE" | awk '{print $4}')

# Generate the diff against the baseline hash, excluding .ipynb files
git diff "${diff_base}"..HEAD -- . ':(exclude)*.ipynb' ':(exclude)**/*.ipynb' > ./tmp/phase_diff.txt
```

#### Step 1.4: Generate Review Request File (Programmatically)
-   Build the review request file using efficient, programmatic shell commands.

```bash
# Define file paths for clarity
PHASE_NAME=$(awk -F': ' "/### \\*\\*Phase $PHASE_NUM:/{print \$2}" "$IMPL_FILE" | head -n 1)
INITIATIVE_NAME=$(grep 'Name:' PROJECT_STATUS.md | sed 's/Name: //')
REVIEW_FILE="$INITIATIVE_PATH/review_request_phase_$PHASE_NUM.md"
PLAN_FILE="$INITIATIVE_PATH/plan.md"
DIFF_FILE="./tmp/phase_diff.txt"

# 1. Create the header of the review request file
{
    echo "# Review Request: Phase $PHASE_NUM - $PHASE_NAME"
    echo ""
    echo "**Initiative:** $INITIATIVE_NAME"
    echo "**Generated:** $(date '+%Y-%m-%d %H:%M:%S')"
    echo ""
    echo "This document contains all necessary information to review the work completed for Phase $PHASE_NUM."
    echo ""
    echo "## Instructions for Reviewer"
    echo ""
    echo "1.  Analyze the planning documents and the code changes (\`git diff\`) below."
    echo "2.  Create a new file named \`review_phase_${PHASE_NUM}.md\` in this same directory (\`$INITIATIVE_PATH/\`)."
    echo "3.  In your review file, you **MUST** provide a clear verdict on a single line: \`VERDICT: ACCEPT\` or \`VERDICT: REJECT\`."
    echo "4.  If rejecting, you **MUST** provide a list of specific, actionable fixes under a \"Required Fixes\" heading."
    echo ""
    echo "---"
} > "$REVIEW_FILE"

# 2. Programmatically append the planning documents
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

# 3. Programmatically append the git diff
{
    echo "---"
    echo "## 2. Code Changes for This Phase"
    echo ""
    echo "**Baseline Commit:** $(grep 'Last Phase Commit Hash:' $IMPL_FILE | awk '{print $4}')"
    echo "**Current Branch:** $(git rev-parse --abbrev-ref HEAD)"
    echo ""
    echo '```diff'
    cat "$DIFF_FILE"
    echo '```'
} >> "$REVIEW_FILE"

echo "✅ Review request file generated programmatically at $REVIEW_FILE"
```

#### Step 1.5: Notify and Halt
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
intended_files_str=$(python -c "
import re
import sys
checklist_path = '$INITIATIVE_PATH/phase_${PHASE_NUM}_checklist.md'
try:
    with open(checklist_path, 'r') as f:
        content = f.read()
    files = re.findall(r'\\\`([a-zA-Z0-9/._-]+)\\\`', content)
    valid_files = {f for f in files if '/' in f and '.' in f}
    print(' '.join(sorted(list(valid_files))))
except FileNotFoundError:
    sys.exit(1)
")
read -r -a intended_files <<< "$intended_files_str"
echo "Verifying staged files against the plan:"
printf " - %s\n" "${intended_files[@]}"

# 2. Get a list of ALL changed files (staged, modified, untracked)
modified_files=$(git status --porcelain | grep -E '^( M| A|AM|MM)' | awk '{print $2}')
untracked_files=$(git status --porcelain | grep '??' | awk '{print $2}')
all_changed_files="${modified_files} ${untracked_files}"

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
#    Check for any remaining unstaged or untracked files.
unintended_changes=$(git status --porcelain | grep -v '^A ') # Ignore already staged files
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
