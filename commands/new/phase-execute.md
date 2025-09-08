# /phase-execute Command

Execute a single phase checklist with AI assistance while maintaining human control at key checkpoints.

## Usage

```bash
/phase-execute plans/active/feature-name/phase_1_checklist.md [flags]
```

**Flags:**
- `--verify-each` - Pause after each task for confirmation
- `--dry-run` - Preview what will be done without executing
- `--learning` - Add explanations for learning
- `--resume-from=N` - Resume from task N after interruption

## What It Does

1. **Analyzes** the phase using subagents to understand context and patterns
2. **Executes** each task in the checklist intelligently
3. **Verifies** work continuously with integration checks
4. **Tests** using the phase's success criteria
5. **Commits** when phase completes successfully
6. **Updates** PROJECT_STATUS.md with progress

## Key Features

### Smart Pattern Recognition
Before implementing anything, subagents research existing patterns in your codebase to ensure consistency.

### Continuous Verification
Every 3-4 tasks, integration checks ensure everything still works together.

### Intelligent Error Recovery
When tasks fail, uses diagnostic subagents to understand why and suggest fixes. Follows a 3-attempt pattern before asking for help.

### Human Checkpoints
- Start of phase (review plan)
- After integration checks (if issues found)
- Before phase commit (final review)
- On any failure after 3 attempts

### Clean Git History
Creates one commit per phase with comprehensive message including what was done, patterns followed, and metrics.

## Execution Flow

```
1. Pre-Phase Analysis
   └─ Subagent analyzes patterns, risks, and dependencies

2. Task Execution Loop
   ├─ For implementation tasks → Find patterns first
   ├─ For test tasks → Generate comprehensive cases
   └─ For refactoring → Analyze impact first

3. Integration Checkpoints (every 3-4 tasks)
   └─ Verify everything works together

4. Success Test
   └─ Run defined test from checklist
   └─ If fails → Diagnostic subagent investigates

5. Phase Completion
   ├─ Create commit with detailed message
   ├─ Update PROJECT_STATUS.md
   └─ Show next phase info
```

## When Subagents Are Used

- **Beginning**: Comprehensive phase analysis
- **Implementations**: Finding similar patterns
- **Tests**: Generating test cases
- **Refactoring**: Impact analysis
- **Failures**: Root cause diagnosis
- **Integration**: Checking system health
- **Documentation**: Generating consistent docs

## Error Handling

When a task fails:
1. **Attempt 1**: Try alternative approach
2. **Attempt 2**: Research solution with subagent
3. **Attempt 3**: Simplified implementation
4. **After 3 failures**: Ask user to:
   - [S]kip and continue
   - [P]ause for manual fix
   - [A]bort phase

## Interruption Support

Press Ctrl+C anytime to pause. Resume with:
```bash
/phase-execute plans/active/feature/phase_1_checklist.md --resume-from=5
```

## Example Session

```bash
User: /phase-execute plans/active/auth-api/phase_1_checklist.md

Claude: Analyzing Phase 1: Core Authentication...

Pre-Phase Analysis:
✓ Found 3 similar auth implementations
✓ Test patterns identified in tests/api/
✓ Architecture guidelines at docs/auth.md:42-89
⚠ Risk: Changes affect user sessions

Proceed with phase? (y/n): y

Task 1/8: Create src/auth/token_validator.py
→ Found pattern in src/auth/basic_auth.py
✓ Created following existing structure

Task 2/8: Implement validate_token() method
→ Using error handling from basic_auth.py:34
✓ Implementation verified

Task 3/8: Add tests/test_token_validator.py
→ Generated 12 test cases based on patterns
✓ All tests passing (12/12)

[Integration Check - All systems healthy]

Task 4/8: Update src/auth/__init__.py
✓ Exports added

[... continuing ...]

Running success test: pytest tests/api/test_auth_integration.py
✓ All tests passed (24/24)

Phase 1 Complete!
- Duration: 28 minutes
- Files: 3 created, 2 modified
- Tests: 12 added (96% coverage)
- Committed: [Auth API] Phase 1: Core token validation

Next: /phase-execute plans/active/auth-api/phase_2_checklist.md
```

## Checklist Format

Your checklist should follow this structure:

```markdown
# Phase N: [Name]

## Tasks
- [ ] Create file: path/to/file.py
- [ ] Implement specific_function() method
- [ ] Add test: tests/test_file.py
- [ ] Update documentation
- [ ] Run integration test

## Success Test
```bash
pytest tests/integration/test_phase.py
```
```

## Best Practices

1. **Keep phases small** - Aim for 5-10 tasks per phase
2. **Define clear success tests** - Must be runnable commands
3. **Include integration tasks** - Update imports, exports, documentation
4. **Order tasks logically** - Create before implement, implement before test
5. **Specify file paths** - Be explicit about where things go

## Comparison with /implement

| Aspect | /implement | /phase-execute |
|--------|------------|----------------|
| Scope | Entire plan | Single phase |
| Control | Automated | Human checkpoints |
| Commits | One at end | One per phase |
| Research | Basic | Deep via subagents |
| Interruption | Limited | Full support |
| Status Updates | End only | Continuous |

## PROJECT_STATUS.md Integration

Automatically updates:
- Progress bar for current phase
- Completion percentage
- Phase metrics (time, files, tests)
- Current task being executed

## Advanced Usage

### Parallel Task Detection
If tasks are independent, executes them simultaneously:
```
Executing in parallel:
├─ Create src/utils/helper.py
├─ Create tests/test_helper.py
└─ Update docs/api.md
```

### Learning Mode
With `--learning`, adds:
- Why each pattern was chosen
- Alternative approaches considered
- Links to relevant documentation
- TODO(human) markers for practice

### Verification Mode
With `--verify-each`, pauses after every task:
```
Task 2/8 complete. Review changes? (y/n/diff):
```

## Tips

- Run `git status` before starting to ensure clean state
- Use `--dry-run` first for complex phases
- Keep PROJECT_STATUS.md open to monitor progress
- Create restore points: `git stash save "before-phase-2"`
- Review the phase commit before pushing

## Common Issues

**"Success test failed"**
- Diagnostic subagent will investigate
- Usually a missing import or wrong test path

**"Can't find similar patterns"**
- May be implementing something new
- Will fall back to general best practices

**"Task too complex"**
- Break it into subtasks in checklist
- Or split into multiple phases

## Requirements

- Git repository
- PROJECT_STATUS.md file
- Checklist in plans/active/
- Defined success test in checklist
- Clean working directory (recommended)

---

The `/phase-execute` command bridges the gap between manual checklist execution and full automation, providing intelligent assistance while keeping you in control of your development process.

