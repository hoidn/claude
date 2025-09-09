# Reusable Claude Code Prompts - Best Practices Collection

> A curated collection of high-value, reusable prompts extracted from real development sessions

## 📋 Table of Contents

- [Project Understanding](#project-understanding)
- [Planning & Architecture](#planning--architecture)
- [Implementation & Refactoring](#implementation--refactoring)
- [Debugging & Troubleshooting](#debugging--troubleshooting)
- [Documentation & Reporting](#documentation--reporting)
- [Git & Workflow Automation](#git--workflow-automation)
- [Testing & Validation](#testing--validation)
- [Advanced Analysis](#advanced-analysis)

---

## Project Understanding

### Initial Project Exploration
```
read proj status architecture.md data contracts and dev guide
```
*Use when: Starting work on a new project or returning after time away*

### Comprehensive Status Check
```
read proj status and active initiative docs
```
*Use when: Need to understand current project state and ongoing work*

### Quick Navigation
```
where is the [feature/component] implemented?
```
*Use when: Locating specific functionality in unfamiliar codebase*

### Dependency Check
```
check that [package/module] is properly configured as a git submodule
```
*Use when: Verifying project dependencies and configuration*

### External Repository Exploration
```
also explore the repo [git@github.com:org/repo.git]
```
*Use when: Need to understand external dependencies or related codebases*

---

## Planning & Architecture

### Deep Planning with Context
```
ultrathink about the plan. then use a subagent to retrieve all proj docs needed to fully understand it in context
```
*Use when: Need comprehensive understanding before major implementation*

### Review Without Implementation
```
review this checklist. don't implement yet. use subagent to find all proj docs relevant to it
```
*Use when: Planning phase requiring thorough review before coding*

### Architecture Critique
```
/plan this is way over engineered. don't create new components (scripts) unless there's a very good reason. ultrathink about simpler approaches
```
*Use when: Evaluating and simplifying complex architectures*

### Implementation Planning Template
```
Implementation Checklist: [Feature Name]
Overall Goal: [Describe the end goal]
Success Criteria: [List measurable outcomes]
Constraints: [List any limitations or requirements]
```
*Use when: Starting any significant feature implementation*

### Deep Understanding Before Implementation
```
read [document/plan] and ultrathink until you understand it. use subagents to gain any understanding needed
```
*Use when: Need thorough comprehension before starting complex work*

### Targeted Context Gathering
```
using a subagent, find and read all proj doc files sections relevant to completing [task/plan]
```
*Use when: Need comprehensive context before implementation*

---

## Implementation & Refactoring

### Structured Implementation Task
```
Task: [Specific Task Name]
Objective: To create/implement/refactor [specific component]
Requirements:
1. [Requirement 1]
2. [Requirement 2]
3. [Requirement 3]
Success Criteria:
- [Criterion 1]
- [Criterion 2]
```
*Use when: Implementing well-defined features or components*

### Apply Specific Changes
```
apply this diff
[paste diff here]
```
*Use when: Have specific code changes to apply*

### Refactoring Request
```
Implementation Checklist: Unify [Component] Logic
Overall Goal: Refactor the [system] to [objective]
Current Issues:
- [Issue 1]
- [Issue 2]
Desired State:
- [Goal 1]
- [Goal 2]
```
*Use when: Systematic refactoring of existing code*

### Step-by-Step Implementation
```
Implementation Plan
Step 1: [First task with specific file/component]
Step 2: [Second task building on step 1]
Step 3: [Third task integrating previous work]
```
*Use when: Breaking down complex features into manageable steps*

### Fully Automated Implementation
```
implement [plan/specification file]. use subagents for all test, debug, verification and doc
```
*Use when: Want comprehensive automation of all supporting tasks*

---

## Debugging & Troubleshooting

### Specific File Investigation
```
investigate why [file/output path] is [problem description]
```
*Use when: Output or file is not as expected*

### Performance Diagnosis
```
diagnose why [script/function] takes up more [resource] than expected
```
*Use when: Identifying performance bottlenecks*

### Diagnosis Without Modification
```
diagnose why [script] takes up much more [resource] than expected. use subagents. dont change the code
```
*Use when: Need analysis only without any code changes*

### Direct Fix Request
```
this is broken. make it work:
[paste broken code]
```
*Use when: Have non-working code that needs fixing*

### Error Analysis
```
[paste error message]
[description of when it occurs]
```
*Use when: Need help understanding and fixing errors*

### Comparative Debugging
```
what's the difference between [file1] and [file2]
```
*Use when: Comparing implementations or outputs*

---

## Documentation & Reporting

### Session Summary Generation
```
write a detailed summary of what was done in this session to a .md under the dir ./history/
```
*Use when: End of significant work session*

### Documentation Update
```
Update Project Documentation with [Topic] Guidance
Objective: To improve the project's documentation by adding:
- [Section 1]
- [Section 2]
- [Section 3]
```
*Use when: Systematic documentation improvements*

### Add Context to Work
```
add a description of what we did to the session summary
```
*Use when: Documenting completed work for future reference*

---

## Git & Workflow Automation

### Selective Branch Merge
```
I want to merge in branch [branch-name], but only the changes under [path1/, path2/, file3.ext]
```
*Use when: Need partial merge of branch changes*

### Selective Git Staging
```
git stage unstaged stuff under [path/] that we want to keep
```
*Use when: Intelligently staging only relevant changes in a directory*

### Smart Commit Creation
```
git diff and write commitmsg to .md dont commit
```
*Use when: Want to review commit message before committing*

### Submodule Addition
```
git add submodule [repository-url] as dir [./directory-path/]
```
*Use when: Adding external dependencies as submodules*

### Repository Cleanup
```
/plan this git repo has large files that were added and then removed but are still in history. create a cleanup strategy
```
*Use when: Repository needs history cleanup*

### Automated Workflow Generation
```
# Command: /generate-agent-checklist
Goal: Autonomously generate and execute a plan to ensure every [requirement] is met
```
*Use when: Need automated workflow for repetitive tasks*

---

## Testing & Validation

### Comprehensive Test Creation
```
Task: Implement and Validate [Feature] Tests
Objective: To create a robust set of automated tests that validate:
1. [Test scenario 1]
2. [Test scenario 2]
3. [Edge cases]
```
*Use when: Building test suites for features*

### Test-First Implementation
```
write tests for [feature/function] before implementing it
```
*Use when: Following TDD practices*

---

## Advanced Analysis

### Multi-Source Analysis
```
using a subagent, clarify what would be required to replace [component A] with [component B] for [use case]
```
*Use when: Evaluating component replacements or alternatives*

### Deep Technical Analysis
```
/plan [describe complex technical challenge]
think about:
- Performance implications
- Security considerations  
- Scalability concerns
- Maintenance burden
```
*Use when: Need thorough technical evaluation*

### Cross-Reference Investigation
```
use a subagent to understand the [component/feature] implementation and how it relates to [other component]
```
*Use when: Understanding component interactions*

---

## Prompt Engineering Tips

### Effective Prompt Patterns

1. **Be Specific**: Include file paths, function names, and exact error messages
2. **State Objectives Clearly**: Start with "Goal:" or "Objective:"
3. **Use Structured Formats**: Checklists and numbered steps work well
4. **Prevent Premature Action**: Add "don't implement yet" when planning
5. **Delegate Complex Research**: Use "use a subagent to..." for information gathering
6. **Provide Context**: Include relevant background information
7. **Set Success Criteria**: Define what successful completion looks like

### Command Modifiers

- `ultrathink about...` - Request deep analysis
- `use a subagent to...` - Delegate research tasks
- `don't implement yet` - Planning only mode
- `/plan` - Structured planning request
- `/generate-agent-checklist` - Automated workflow creation

### Session Management

- Start sessions with comprehensive status reads
- End sessions with summary generation
- Use structured templates for complex tasks
- Break large tasks into numbered steps
- Document decisions and rationale

---

## Examples of Combining Prompts

### Complex Feature Implementation
```
1. read proj status architecture.md and dev guide
2. review this checklist. don't implement yet. use subagent to find all proj docs relevant to it
3. ultrathink about the plan and identify potential issues
4. Implementation Checklist: [Feature]...
5. write a detailed summary of what was done to ./history/
```

### Debugging Session
```
1. read proj status
2. investigate why [issue]
3. diagnose why [performance issue]
4. this is broken. make it work: [code]
5. add a description of what we fixed to the session summary
```

---

*Last Updated: Based on analysis of 250+ real development sessions (including shards 05-06)*
*Note: Adapt these prompts to your specific context and requirements*