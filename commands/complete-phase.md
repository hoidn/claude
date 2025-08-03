# Command: /complete-phase

**Goal:** Manage the end-of-phase transition using a formal review cycle and a hardened, intent-driven Git commit process. This command operates in two distinct modes, determined by the presence of a review file.

---

## 🔴 **CRITICAL: MANDATORY EXECUTION FLOW**

**You MUST operate in one of two modes. You are not allowed to mix them.**

**Mode 1: Request Review (Default)**
*   **Trigger:** No `review_phase_N.md` file exists for the current phase.
*   **Action:** You MUST generate a `review_request_phase_N.md` file containing a `git diff` and then HALT.

**Mode 2: Process Review**
*   **Trigger:** A `review_phase_N.md` file EXISTS for the current phase.
*   **Action:** You MUST read the review, parse the `VERDICT`, and then either commit the changes (on `ACCEPT`) using the new **safe staging protocol** or report the required fixes (on `REJECT`).

**DO NOT:**
-   ❌ Commit any code without a `VERDICT: ACCEPT` from a review file.
-   ❌ Use `git add -A` or `git add .`. You must use the new, explicit staging logic.
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

#### Step 1.1: Read State and Generate Diff
-   Read `<path>/implementation.md` to get the `Last Phase Commit Hash`. This is your diff base.
-   Run the following command to generate the diff.

```bash
# Ensure a temporary directory exists
mkdir -p ./tmp

# Extract the baseline commit hash for the diff
diff_base=$(grep 'Last Phase Commit Hash:' <path>/implementation.md | awk '{print $4}')

# Generate the diff against the baseline hash, excluding .ipynb files
git diff "${diff_base}"..HEAD -- . ':(exclude)*.ipynb' ':(exclude)**/*.ipynb' > ./tmp/phase_diff.txt
```

#### Step 1.2: Generate Review Request File
-   Create a new file: `<path>/review_request_phase_N.md`.
-   Populate it using the "REVIEW REQUEST TEMPLATE" below.

#### Step 1.3: Notify and Halt
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
# 1. Identify Intended Files from the Checklist
#    This Python script robustly parses all file paths from the checklist.
intended_files_str=$(python -c "
import re
import sys
checklist_path = '<path>/phase_N_checklist.md' # Agent must substitute the correct path
try:
    with open(checklist_path, 'r') as f:
        content = f.read()
    # Find all file paths enclosed in backticks
    files = re.findall(r'\`([a-zA-Z0-9/._-]+)\`', content)
    # Filter for valid-looking file paths and print unique ones
    valid_files = {f for f in files if '/' in f and '.' in f}
    print(' '.join(sorted(list(valid_files))))
except FileNotFoundError:
    sys.exit(1)
")

if [ $? -ne 0 ]; then
    echo "❌ ERROR: Could not parse the phase checklist to determine which files to commit."
    exit 1
fi

# Convert the string of files into a bash array
read -r -a intended_files <<< "$intended_files_str"
echo "Plan indicates the following files should be modified:"
printf " - %s\n" "${intended_files[@]}"

# 2. Get a list of currently modified and new files from git status
modified_files=$(git status --porcelain | grep -E '^( M| A|AM|MM)' | awk '{print $2}')
untracked_files=$(git status --porcelain | grep '??' | awk '{print $2}')
all_changed_files="${modified_files} ${untracked_files}"

# 3. Explicitly Stage Intended Files
#    Only stage files that are both changed AND were mentioned in the plan.
echo "Staging the following intended and modified files:"
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
#    Check for any remaining unstaged or untracked files that were NOT in the plan.
unintended_changes=$(git status --porcelain)
if [ -n "$unintended_changes" ]; then
    echo "❌ ERROR: Unplanned changes detected. The following files were modified or created but were not part of the phase plan:"
    echo "$unintended_changes"
    echo "Please review these files. Either add them to the phase checklist or revert them before committing."
    exit 1
fi

# 5. Commit the Staged Changes
echo "Committing staged changes..."
phase_deliverable="<Extract Deliverable from implementation.md for the current phase>"
git commit -m "Phase N: $phase_deliverable"

# 6. Verify the commit was successful and capture the new hash
if [ $? -ne 0 ]; then
    echo "❌ ERROR: Git commit failed. Halting."
    exit 1
fi
new_hash=$(git rev-parse HEAD)
echo "New commit hash is: $new_hash"

# 7. Proceed with State Updates
#    (Update implementation.md, PROJECT_STATUS.md, etc.)
```

---

## 템플릿 & 가이드라인 (Templates & Guidelines)

### **REVIEW REQUEST TEMPLATE**
*This is the content for the agent-generated `review_request_phase_N.md`.*
```markdown
# Review Request: Phase <N> - <Phase Name>

**Initiative:** <Initiative Name>
**Generated:** <YYYY-MM-DD HH:MM:SS>

This document contains all necessary information to review the work completed for Phase <N>.

## Instructions for Reviewer

1.  Analyze the planning documents and the code changes (`git diff`) below.
2.  Create a new file named `review_phase_N.md` in this same directory (`<path>/`).
3.  In your review file, you **MUST** provide a clear verdict on a single line: `VERDICT: ACCEPT` or `VERDICT: REJECT`.
4.  If rejecting, you **MUST** provide a list of specific, actionable fixes under a "Required Fixes" heading.

---
## 1. Planning Documents

### R&D Plan (`plan.md`)
<The full content of plan.md is embedded here>

### Implementation Plan (`implementation.md`)
<The full content of implementation.md is embedded here>

### Phase Checklist (`phase_N_checklist.md`)
<The full content of the current phase_N_checklist.md is embedded here>

---
## 2. Code Changes for This Phase

**Baseline Commit:** `<Last Phase Commit Hash from implementation.md>`
**Current Branch:** `<current feature branch name>`
**Changes since last phase:**
*Note: Jupyter notebook (.ipynb) files are excluded from this diff for clarity*

```diff
<The full output of the 'git diff' command is embedded here>
```
```

### **REVIEW FILE TEMPLATE (for human reviewers)**
*This is the expected format of the human-created `review_phase_N.md`.*
```markdown
# Review: Phase <N> - <Phase Name>

**Reviewer:** <Reviewer's Name>
**Date:** <YYYY-MM-DD>

## Verdict

**VERDICT: ACCEPT**

---
## Comments

The implementation looks solid. The new module is well-tested and follows project conventions.

---
## Required Fixes (if REJECTED)

*(This section would be empty for an ACCEPT verdict)*
- **Fix 1:** In `src/module/file.py`, the error handling for `function_x` is incomplete. It must also catch `KeyError`.
- **Fix 2:** The unit test `tests/test_module.py::test_function_x_edge_case` does not assert the correct exception type.
