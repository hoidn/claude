---
name: update-docs
description: Update project documentation to match code changes
---

Review code changes and ensure all project documentation is consistent with them, incorporating any user-provided suggestions.

**Usage:** `/update-docs [optional guidance about what to document]`

**Examples:**
- `/update-docs` - Review staged changes and update docs automatically
- `/update-docs Added new --verbose flag to main.py, need to update CLI docs`
- `/update-docs The detector geometry fix changes the coordinate system conventions`

**User guidance:** $ARGUMENTS

## Prerequisites
- Must be run from a git repository root
- Works with either staged changes (`git diff --staged`) or recent commits

## Your Task

1. **Identify what needs documenting**
   - If user provided guidance above, follow their suggestions
   - Otherwise, check staged changes with `git diff --staged`
   - If no staged changes, review recent commits or ask user for clarification
   - Identify which components/features are affected

2. **Review and update documentation**
   Systematically check these documentation categories:
   
   ### High-Level Documentation
   - **README.md**: Update if there are changes to:
     - Major features or capabilities
     - Installation or setup instructions
     - Usage examples or commands
     - Dependencies or requirements
   
   - **docs/architecture/README.md**: Update if there are:
     - New architectural components
     - Significant changes to existing components
     - New or modified component relationships
   
   - **docs/DEVELOPER_GUIDE.md** (if exists): Update for:
     - New architectural principles or patterns
     - Critical workflows or best practices
     - Lessons learned or anti-patterns to avoid
     - Data pipeline or evaluation method changes
   
   - **CLAUDE.md**: Add or update if there are:
     - New critical conventions or patterns
     - Important "gotchas" or edge cases discovered
     - New mandatory workflows for AI agents
     - Changes to core implementation rules
   
   ### Component & Data Documentation
   - **Component specifications** (docs/architecture/*.md): Update for:
     - Changed function signatures or APIs
     - Modified return values or data structures
     - New or altered conventions
     - Updated unit systems or coordinate systems
   
   - **docs/data_contracts.md** (if exists): Update for:
     - New data formats or file types
     - Changes to array shapes, types, or keys
     - Modified data pipeline specifications
   
   ### Code-Level Documentation
   - **Python docstrings**: For new/modified Python files:
     - Module-level docstrings explaining purpose
     - Function/class docstrings with Args:, Returns:, Raises:
     - Usage examples where helpful
   
   - **Shell script headers**: For new/modified .sh files:
     - Purpose and usage in header comments
     - Document all arguments and options
     - Provide example invocations
   
   - **Script README files**: For new script directories:
     - Create README.md explaining the directory's purpose
     - Document workflows and dependencies
     - Provide clear usage examples

3. **Regenerate documentation index**
   - Create or update `docs/index.md` with the current documentation structure
   - Include all markdown files found in the documentation directories
   - Organize by category (architecture, development, debugging, user guides, etc.)
   - Maintain clear navigation hierarchy with relative links
   - Include brief descriptions where helpful

4. **Final consistency check**
   - Review all documentation changes for consistency
   - Ensure terminology is uniform across documents
   - Verify examples align with actual code behavior
   - Check that cross-references are valid

5. **Stage documentation changes**
   - Stage all modified documentation files with `git add`
   - Provide a clear summary of what was updated
   - DO NOT stage non-documentation files
   - DO NOT commit - only stage the changes

## Important Constraints

- Only modify documentation files (*.md, *.txt in docs/)
- Preserve the existing documentation structure and style
- Keep updates minimal and directly relevant to the staged changes
- If no documentation updates are needed, clearly report that
- Maintain consistency with existing documentation tone and format
- Use relative links for internal documentation references

## Example Scenarios

**Scenario 1**: A new utility function is added
- Add docstring to the function with Args:, Returns:
- Check if it needs mentioning in component specs
- Update affected usage examples in README if applicable

**Scenario 2**: A core component's API changes
- Update the component's specification in docs/architecture/
- Update CLAUDE.md if there are new conventions
- Update README if user-facing commands change
- Update docstrings for all affected functions

**Scenario 3**: Data format changes (e.g., new NPZ keys)
- Update docs/data_contracts.md with new format
- Update any scripts that generate/consume the data
- Add migration notes if breaking change

**Scenario 4**: New script directory created
- Create README.md in the new directory
- Document the workflow and purpose
- Add shell script header comments

**Scenario 5**: Bug fix with no API changes
- Likely no documentation updates needed
- Report that documentation is already consistent

## Success Criteria

✅ All relevant documentation reflects the staged code changes
✅ Documentation index (docs/index.md) is current and complete
✅ All documentation changes are staged for commit
✅ Clear report of what was updated (or that no updates were needed)
