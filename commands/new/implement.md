# /implement Command - Adaptive Implementation Protocol

## Command: /implement <plan_file>

**Philosophy**: Execute implementation plans using proven patterns from real development sessions, emphasizing deep understanding before action and continuous documentation.

## Usage
```bash
/implement plans/active/feature.md [--ultrathink] [--with-history]
```

### Flags
- `--ultrathink`: Deep analysis at each major decision point
- `--with-history`: Generate detailed history file after each phase

## Core Implementation Pattern

### Phase 0: Deep Context Gathering

When I receive `/implement <plan_file>`, I will begin with comprehensive reconnaissance:

```
1. read proj status architecture.md data contracts and dev guide
2. read CLAUDE.md if it exists
3. read the plan file: <plan_file>
4. read any active initiative docs referenced in the plan
```

### Phase 1: Plan Analysis & Understanding

```
review this checklist. don't implement yet. use subagent to find all proj docs relevant to it and to fully understand the implementation context

ultrathink about the plan. Consider:
- What are the core components that need to be built?
- What existing patterns in the codebase should I follow?
- What are the riskiest parts that need careful attention?
- What's the optimal implementation sequence?
- What context will I need for each component?
```

Create structured implementation checklist:
```markdown
Implementation Checklist: [Feature Name from Plan]
Overall Goal: [Extracted from plan]
Success Criteria:
- [ ] All components compile
- [ ] Tests pass for each component
- [ ] Follows existing patterns from codebase
- [ ] [Additional criteria from plan]

Phase Breakdown:
1. [First logical unit of work]
2. [Second logical unit]
3. [Integration phase]
```

### Phase 2: Adaptive Implementation Loop

For each phase in the checklist, follow this pattern:

#### 2.1 Research & Context Gathering
```
use a subagent to understand the [relevant component/pattern] implementation and how it relates to [what I'm building]

Search for existing patterns:
- Find similar implementations
- Identify test patterns
- Locate relevant documentation
```

#### 2.2 Structured Implementation Task
```markdown
Task: [Specific Component Name]
Objective: To implement [specific functionality]
Context Gathered:
- Existing pattern found in: [file:line]
- Test pattern from: [test_file:line]
- Follows convention from: [doc_reference]

Requirements:
1. [Specific requirement from plan]
2. [Inferred requirement from codebase patterns]
3. [Test coverage requirement]

Implementation Approach:
- [Step 1 with rationale]
- [Step 2 with rationale]
```

#### 2.3 Test-First When Appropriate
```
For critical components:
1. Write failing test based on discovered patterns
2. Run test to confirm it fails properly
3. Implement minimal code to pass
4. Run test suite to verify
5. Refactor following project conventions
```

#### 2.4 Incremental Verification
```bash
After each component:
- Run relevant tests
- Check compilation/linting
- Verify against success criteria
- Document any deviations or discoveries
```

### Phase 3: Integration & Polish

#### 3.1 Cross-Component Verification
```
investigate why [any integration issues between components]
diagnose why [any performance concerns]
use a subagent to verify all integration points are correct
```

#### 3.2 Final Validation
```bash
Run complete test suite:
- Project-specific test command
- Linting and formatting
- Any custom validation scripts
```

#### 3.3 Documentation Generation
```markdown
write a detailed summary of implementation to ./history/[date]_[feature]_implementation.md

## Implementation Summary: [Feature Name]

### Context
- Plan file: [plan_file]
- Start time: [timestamp]
- Completion time: [timestamp]

### What Was Implemented
[Detailed description of each component]

### Key Decisions
- [Decision 1 with rationale]
- [Decision 2 with rationale]

### Files Modified
- [file1]: [what was changed and why]
- [file2]: [what was changed and why]

### Test Results
- Tests added: [number]
- Tests passing: [x/y]
- Coverage change: [if applicable]

### Deviations from Plan
[Any changes made to original plan and why]

### Next Steps
[What remains to be done, if anything]
```

### Phase 4: Commit & Wrap-up

```bash
If all tests pass:
1. git diff and write comprehensive commit message
2. Stage all changes
3. Create semantic commit referencing the plan
4. Update project status if applicable
```

## Intelligent Decision Points

### When to Use Subagents

Automatically delegate to subagents when:
```
- "use a subagent to understand the [complex component]"
- "use a subagent to find all instances of [pattern]"
- "use a subagent to research [external library usage]"
```

### When to Ultrathink

Trigger deep analysis when:
```
- Facing architectural decisions
- Multiple valid implementation approaches exist
- Performance implications are unclear
- Security considerations are present
```

### When to Stop and Ask

Pause for user input when:
```
- Plan is ambiguous or contradictory
- After 3 failed attempts at any component
- Critical architectural decision lacks context
- Tests reveal unexpected breaking changes
```

## Adaptive Patterns

### Pattern A: Simple Feature Addition
```
1. read proj status and relevant docs
2. find similar existing features
3. implement following discovered pattern
4. add tests matching existing test patterns
5. write summary to history/
```

### Pattern B: Complex Refactoring
```
1. read all relevant architecture docs
2. ultrathink about the refactoring approach
3. use subagent to map all dependencies
4. implement in small, testable increments
5. verify each step doesn't break existing tests
6. document all changes and rationale
```

### Pattern C: Greenfield Component
```
1. read architecture.md and design patterns
2. review similar components in other projects
3. write comprehensive tests first
4. implement with regular verification
5. integrate carefully with existing system
6. create detailed documentation
```

## Example Session Flow

```
User: /implement plans/active/auth-refactor.md --ultrathink

Claude: I'll implement the auth refactor plan with deep analysis at each step.

Starting with comprehensive context gathering...
[reads proj status, architecture.md, dev guide, plan file]

Now let me review this plan without implementing yet. I'll use a subagent to find all relevant documentation...
[subagent gathers auth-related docs]

Let me ultrathink about this refactoring approach...
[deep analysis of plan, risks, and approach]

I've created this implementation checklist:
[shows structured checklist]

Phase 1: Refactor TokenValidator
First, let me understand the existing token validation pattern...
[searches for patterns, implements, tests]

[continues through phases with detailed feedback]

Implementation complete. I've written a detailed summary to history/2025-01-08_auth_refactor.md

All tests passing (47/47). Ready for review.
```

## Key Principles

1. **Understanding First**: Never implement without understanding context
2. **Pattern Recognition**: Always find and follow existing patterns
3. **Incremental Progress**: Each change is small, testable, verifiable
4. **Documentation Throughout**: Create artifacts during process, not after
5. **Intelligent Delegation**: Use subagents for research and analysis
6. **Adaptive Execution**: Adjust approach based on discoveries
7. **User Partnership**: Pause for input at critical decisions

## Integration with Claude Code Ecosystem

- Leverages all native tools (Read, Grep, Task, Bash, etc.)
- Respects CLAUDE.md guidelines
- Uses TodoWrite for complex multi-phase plans
- Creates history/ artifacts for knowledge preservation
- Follows project-specific conventions discovered during reconnaissance
- Integrates with existing test/build infrastructure

## Notes

This command adapts to the complexity and style of each project, using patterns proven effective across hundreds of real development sessions. It emphasizes understanding and documentation as much as implementation, creating a sustainable development process.

