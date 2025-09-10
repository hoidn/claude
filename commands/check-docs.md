---
name: check-docs
description: Quick audit of documentation completeness without creating missing files
---

Perform a quick audit of project documentation to identify what exists and what's missing.

**Usage:** `/check-docs [optional specific area to check]`

**Examples:**
- `/check-docs` - Full documentation audit
- `/check-docs architecture` - Check only architecture docs
- `/check-docs data contracts` - Focus on data documentation

**User guidance:** $ARGUMENTS

## Your Task

### 1. Quick Documentation Scan

Check for the existence of standard documentation files and provide a status report.

**Check these categories:**

#### Core Project Documentation
- [ ] `README.md` - Main project overview
- [ ] `CLAUDE.md` - AI agent instructions
- [ ] `PROJECT_STATUS.md` - Current development status
- [ ] `CHANGELOG.md` - Version history
- [ ] `CONTRIBUTING.md` - How to contribute
- [ ] `LICENSE` - Legal terms
- [ ] `.gitignore` - Git ignore rules

#### Documentation Structure
- [ ] `docs/` directory exists
- [ ] `docs/index.md` - Documentation hub
- [ ] `docs/architecture/` directory
- [ ] `docs/development/` directory
- [ ] `docs/debugging/` directory
- [ ] `docs/user/` directory

#### Architecture Documentation
- [ ] `docs/architecture/README.md` - Architecture navigation
- [ ] Component specifications (*.md files)
- [ ] Design documents
- [ ] System diagrams or descriptions

#### Development Documentation
- [ ] `docs/development/README.md` - Dev guide hub
- [ ] `docs/development/testing_strategy.md` - Testing approach
- [ ] `docs/development/debugging.md` - Debug workflows
- [ ] Implementation plans or roadmaps
- [ ] Configuration mappings

#### Data & API Documentation
- [ ] `docs/data_contracts.md` - Data format specs
- [ ] `docs/api_reference.md` - API documentation
- [ ] Schema definitions
- [ ] Integration guides

#### User Documentation
- [ ] `docs/user/installation.md` - Setup guide
- [ ] `docs/user/quickstart.md` - Getting started
- [ ] `docs/user/tutorials/` - Tutorial directory
- [ ] FAQ or troubleshooting guides

#### Command Documentation
- [ ] `.claude/commands/` directory
- [ ] Custom command definitions
- [ ] Command documentation

### 2. Generate Status Report

Create a structured report showing:

```markdown
# Documentation Audit Report

## Summary
- Total expected: [number]
- Found: [number]
- Missing: [number]
- Coverage: [percentage]

## Existing Documentation
### Core Files ✅
- README.md (last modified: date)
- [other existing files...]

### Architecture Docs ✅
- [existing architecture docs...]

## Missing Documentation
### Critical Priority 🔴
These files are essential for project functionality:
- [missing file] - [why it's critical]

### High Priority 🟡
These files significantly impact usability:
- [missing file] - [impact of absence]

### Nice to Have 🟢
These would improve the project:
- [missing file] - [benefit if added]

## Recommendations
1. [Prioritized action items]
2. [Suggested next steps]

## Quick Fixes
[Any documentation that could be quickly generated]

## Command to Create Missing Docs
To automatically create the missing documentation with deep analysis:
`/init-docs [optional focus area]`
```

### 3. Additional Checks

**Documentation Quality Indicators:**
- Check if README has basic sections (Installation, Usage, Contributing)
- Verify if docs/index.md is up-to-date with current structure
- Look for broken internal links in documentation
- Check for TODO or FIXME markers in docs
- Identify stale documentation (very old modification dates)

**Project-Specific Checks:**
- For Python projects: Check for docstrings in main modules
- For scientific projects: Check for units/coordinates documentation
- For APIs: Check for OpenAPI/Swagger specs
- For CLIs: Check for --help documentation

### 4. Smart Recommendations

Based on the audit, provide smart recommendations:

- If missing critical docs: Suggest running `/init-docs`
- If docs are stale: Suggest running `/update-docs`
- If structure is incomplete: Recommend directory creation
- If project type is detected: Suggest specific documentation needs

## Output Format

Provide a clear, actionable report that:
1. Shows current documentation coverage at a glance
2. Prioritizes missing documentation by importance
3. Offers specific next steps
4. Avoids overwhelming with too much detail
5. Includes commands to fix issues

## Success Criteria

✅ Complete audit of all standard documentation locations
✅ Clear report of what exists and what's missing
✅ Prioritized list of missing documentation
✅ Actionable recommendations for improvement
✅ No files are created or modified (audit only)