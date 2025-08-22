# Command: /complete-phase

**Goal:** Manage the end-of-phase transition using a formal review cycle and a hardened, intent-driven Git commit process. This command operates in two distinct modes, determined by the presence of a review file.

---

## 🔴 **CRITICAL: MANDATORY EXECUTION FLOW**

**You MUST operate in one of two modes. You are not allowed to mix them.**

**Mode 1: Request Review (Default)**
*   **Trigger:** No `review_phase_N.md` file exists for the current phase.
*   **Action:** You MUST execute the **Review Request Generation Protocol** below **in its entirety as a single, atomic script**. Do not modify it or run it in pieces. After execution, you MUST HALT.

**Mode 2: Process Review**
*   **Trigger:** A `review_phase_N.md` file EXISTS for the current phase.
*   **Action:** You MUST read the review, parse the `VERDICT`, and then either commit the changes (on `ACCEPT`) using the **Safe Staging and Commit Protocol** or report the required fixes (on `REJECT`).

**DO NOT:**
-   ❌ Commit any code without a `VERDICT: ACCEPT` from a review file.
-   ❌ Use `git add -A` or `git add .`. You must use the explicit, plan-driven staging logic.
-   ❌ **Abandon the provided scripts.** If a script fails, report the complete error message and STOP. Do not attempt to "fix" it by running commands manually; the script's atomicity is essential for safety.

---

## 📋 **YOUR EXECUTION WORKFLOW**

### Step 1: Determine Current Mode
1.  Read `PROJECT_STATUS.md` to find the path and phase number (`N`) of the **current active initiative**.
2.  Check if the file `<path>/review_phase_N.md` exists.
3.  If it exists, proceed to **Mode 2: Process Review**.
4.  If it does not exist, proceed to **Mode 1: Request Review**.

---

### **MODE 1: REQUEST REVIEW**

#### **Review Request Generation Protocol (v3 - Enhanced)**
You will now execute the following shell script block in its entirety. It is designed to be robust against common failures like multi-entry status files and large, untracked repository files.

Run the follwing bash command:
```bash
./.claude/scripts/generate_git_context.sh 
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

#### **Safe Staging and Commit Protocol (v3 - Enhanced)**
If `VERDICT: ACCEPT`, you MUST execute this precise sequence of commands as a single script.

```bash
#!/bin/bash
set -e
set -o pipefail

fail() {
    echo "❌ ERROR: $1" >&2
    exit 1
}

# 1. ROBUST PARSING
read INITIATIVE_PATH PHASE_NUM < <(awk '
  /^### / { in_active = 0 }
  /^### Current Active Initiative/ { in_active = 1 }
  in_active && /^Path:/ { path = $2; gsub(/`/, "", path) }
  in_active && /^Current Phase:/ { phase = $3; sub(":", "", phase) }
  END { if (path && phase) print path, phase }
' PROJECT_STATUS.md)

[ -z "$INITIATIVE_PATH" ] && fail "Could not parse INITIATIVE_PATH."
[ -z "$PHASE_NUM" ] && fail "Could not parse PHASE_NUM."

CHECKLIST_FILE="$INITIATIVE_PATH/phase_${PHASE_NUM}_checklist.md"
IMPL_FILE="$INITIATIVE_PATH/implementation.md"
[ ! -f "$CHECKLIST_FILE" ] && fail "Checklist file not found: $CHECKLIST_FILE."
[ ! -f "$IMPL_FILE" ] && fail "Implementation file not found: $IMPL_FILE."

# 2. PARSE THE PLAN
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
[ -z "$intended_files_str" ] && fail "Could not parse any intended files from checklist."
read -r -a intended_files_array <<< "$intended_files_str"
echo "INFO: Staging files according to plan:"
printf " - %s\n" "${intended_files_array[@]}"

# 3. FAST & TARGETED STAGING: Explicitly stage ONLY intended files.
git add "${intended_files_array[@]}"
echo "✅ INFO: Staged all planned files."

# 4. HALT ON UNPLANNED CHANGES: Verify no other files were modified.
# We check the status of the *entire repo* here, but EXCLUDE the files we just staged.
# This is the one place a full 'git status' is required, to ensure repo cleanliness.
unintended_changes=$(git status --porcelain | grep -v '^A[ M]')
if [ -n "$unintended_changes" ]; then
    echo "Unplanned changes detected:"
    echo "$unintended_changes"
    fail "The repository contains modified or untracked files not in the phase plan. Please revert them or add them to the checklist."
fi

# 5. COMMIT
phase_deliverable=$(awk -F': ' "/^\\*\\*Deliverable\\*\\*/{print \$2}" "$IMPL_FILE" | head -n 1)
commit_message="feat: Phase $PHASE_NUM - $phase_deliverable"
echo "INFO: Committing with message: '$commit_message'"
git commit -m "$commit_message"
new_hash=$(git rev-parse HEAD)
echo "✅ Commit successful. New commit hash: $new_hash"

# 6. UPDATE STATE FILES
echo "INFO: Updating state files..."

# Update implementation.md with new commit hash
sed -i "s/Last Phase Commit Hash: .*/Last Phase Commit Hash: $new_hash/" "$IMPL_FILE"

# Update PROJECT_STATUS.md
# First, calculate next phase
NEXT_PHASE=$((PHASE_NUM + 1))
TOTAL_PHASES=$(grep -c "^### \*\*Phase [0-9]" "$IMPL_FILE")

if [ "$NEXT_PHASE" -le "$TOTAL_PHASES" ]; then
    # Update to next phase
    sed -i "/^### Current Active Initiative/,/^###/ {
        s/Current Phase: Phase [0-9]*/Current Phase: Phase $NEXT_PHASE/
    }" PROJECT_STATUS.md
    echo "✅ Advanced to Phase $NEXT_PHASE"
else
    # Initiative complete
    sed -i "/^### Current Active Initiative/,/^###/ {
        s/Status: .*/Status: Completed/
        s/Current Phase: .*/Current Phase: Completed/
    }" PROJECT_STATUS.md
    echo "✅ Initiative completed!"
fi

echo "✅ State files updated successfully."
```
