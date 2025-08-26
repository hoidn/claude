# Command: /postmortem [issue_description]

**Goal:** Analyze why a bug/regression occurred, audit relevant documentation, and implement systematic improvements to prevent recurrence.

---

## 🎯 **PURPOSE**

This command performs a comprehensive postmortem analysis that:
1. Investigates root causes of bugs/regressions
2. Audits existing documentation and guidelines
3. Implements protective measures (tests, assertions, docs)
4. Updates project conventions to prevent future occurrences

---

## 🤖 **CONTEXT: YOU ARE CLAUDE CODE**

You execute this entire workflow autonomously:
- ✅ Run git analysis to find when/why issues were introduced
- ✅ Deploy subagents to audit documentation
- ✅ Implement protective measures directly
- ✅ Update guidelines and conventions
- ❌ NO waiting for user confirmation between steps

---

## 📋 **EXECUTION WORKFLOW**

### Phase 1: Issue Investigation

```bash
# 1. Git forensics
git log --oneline --grep="<relevant_keywords>" -20
git blame <file> | grep -C3 "<critical_line>"
git log -p --follow <file> | grep -B10 -A10 "<pattern>"

# 2. Check for patterns
git log --oneline | grep -E "(fix|bug|regression|revert)" | head -20

# 3. Find when issue was introduced
git bisect start
git bisect bad HEAD
git bisect good <known_good_commit>
```

### Phase 2: Documentation Audit (via Subagent)

Deploy a subagent to comprehensively audit documentation:

```
/subagent: Audit documentation quality and discoverability for [specific topic]:

1. **Entry Point Analysis** (starting from CLAUDE.md):
   - Is the issue/concept documented?
   - How many clicks/links to find relevant info?
   - Rate discoverability (1-5)

2. **Point-of-Danger Documentation**:
   - Check the actual code location where bug occurred
   - Are there warning comments?
   - Are there links to documentation?
   - Are error messages helpful?

3. **Coverage Gaps**:
   - What's documented but hard to find?
   - What's missing entirely?
   - What's outdated or contradictory?

4. **Developer Journey Mapping**:
   - How would a developer debugging this issue find help?
   - What search terms would they use?
   - Where would they look first?

Return:
- Specific files and line numbers needing improvement
- Discoverability score for each relevant doc
- List of missing documentation
- Recommended improvements with priority
```

### Phase 3: Root Cause Analysis

Analyze findings to identify systemic issues:

1. **Technical Root Causes**:
   - Missing validation/assertions
   - Inadequate test coverage  
   - Unclear interfaces or contracts
   - Hidden dependencies or side effects

2. **Documentation Root Causes**:
   - Concepts well-documented but not discoverable
   - Missing point-of-danger warnings
   - No connection from symptoms to documentation
   - Outdated or incorrect information

3. **Process Root Causes**:
   - Missing code review checks
   - No regression tests for previous bugs
   - Unclear ownership or responsibility
   - Missing continuous validation

### Phase 4: Implement Protections

Based on root causes, implement appropriate measures:

#### A. Code-Level Protection
```python
# Add assertions at critical points
assert condition, f"Helpful error: see docs/GUIDE.md#section"

# Add defensive checks
if unexpected_state:
    raise ValueError(
        f"State error: {details}\n"
        f"Common cause: [explanation]\n" 
        f"Fix: See docs/TROUBLESHOOTING.md#topic"
    )
```

#### B. Test Protection
```python
def test_regression_[issue_name](self):
    """Regression test for [issue description]."""
    # Minimal test that would catch the bug
    # Include assertion message explaining what broke
```

#### C. Documentation Protection
- Add warnings at point-of-danger in code
- Create symptom-to-solution mapping in troubleshooting guide
- Update relevant guides with lessons learned
- Add cross-references between related docs

### Phase 5: Update Project Conventions

Based on patterns found, update project guidelines:

1. **Testing Conventions** (`docs/TESTING_GUIDE.md`):
   - New requirement for regression tests
   - Specific test patterns for this issue type
   - Assertion message standards

2. **Code Conventions** (`CLAUDE.md`, `docs/DEVELOPER_GUIDE.md`):
   - New defensive programming requirements
   - Required assertions for critical operations
   - Documentation requirements for danger zones

3. **Documentation Standards**:
   - Required warnings for common pitfalls
   - Symptom-to-documentation mapping requirements
   - Point-of-danger documentation rules

---

## 🔍 **EXAMPLE EXECUTION**

For a scaling bug regression:

```bash
# Phase 1: Investigation
git log -p --follow ptycho/diffsim.py | grep -B5 -A5 "intensity_scale"
# Found: Bug introduced in commit X, removed critical scaling

# Phase 2: Documentation Audit (via subagent)
# Subagent finds:
# - Normalization well-documented in guides
# - ZERO warnings at line 123 where bug occurs  
# - No error messages point to documentation
# - Discoverability from error: 0/5

# Phase 3: Root Cause
# Technical: Missing assertion to verify scaling
# Documentation: Point-of-danger blindness
# Process: No regression test from previous occurrence

# Phase 4: Implement Protections
# - Add assertion at line 123
# - Create test_scaling_regression.py
# - Add warning comment with doc reference
# - Update error messages to guide to docs

# Phase 5: Update Conventions
# - TESTING_GUIDE.md: Require regression tests
# - DEVELOPER_GUIDE.md: Require assertions at data transformations
# - Add point-of-danger documentation requirement
```

---

## ⚠️ **CRITICAL SUCCESS FACTORS**

1. **Deploy Subagents Properly**:
   - Give them specific, measurable audit criteria
   - Ask for concrete line numbers and files
   - Request priority rankings for improvements

2. **Focus on Discoverability**:
   - Entry-point discoverability (from CLAUDE.md)
   - Point-of-danger discoverability (at error site)
   - Symptom-based discoverability (from errors)

3. **Implement Defense in Depth**:
   - Never rely on documentation alone
   - Always add executable specifications (tests/assertions)
   - Make the code defend itself

4. **Update Systematically**:
   - Don't just fix the immediate issue
   - Update conventions to prevent entire class of issues
   - Create patterns others can follow

---

## ✅ **EXECUTION CHECKLIST**

- [ ] Investigated issue history with git forensics
- [ ] Deployed subagent for documentation audit
- [ ] Identified all root causes (technical/docs/process)
- [ ] Implemented code-level protections
- [ ] Created regression tests
- [ ] Updated documentation at point-of-danger
- [ ] Modified project conventions/guidelines
- [ ] Verified protections catch the issue

---

## 📊 **OUTPUT FORMAT**

```markdown
## Postmortem: [Issue Description]

### Executive Summary
- **Issue:** [What happened]
- **Impact:** [Who/what was affected]  
- **Root Cause:** [Primary cause]
- **Fixed:** [Yes/No with commit refs]

### Timeline
- [Date]: Issue introduced (commit XXX)
- [Date]: Issue discovered
- [Date]: Fix implemented

### Root Cause Analysis

#### Technical Causes
- [Specific technical failure]

#### Documentation Gaps
- **Discoverability Score:** X/5 from entry point, 0/5 from error
- [Specific gaps found]

#### Process Failures  
- [Specific process that failed]

### Implemented Protections

#### Code Changes
- [File:line] - Added assertion
- [File:line] - Added defensive check

#### New Tests
- tests/test_XXX.py - Regression test

#### Documentation Updates
- [File] - Added warning at danger point
- [File] - Updated troubleshooting guide

#### Convention Updates
- [Guide] - New requirement: [description]

### Lessons Learned
1. [Key learning]
2. [Key learning]

### Follow-up Actions
- [ ] [Any remaining tasks]
```

---

## 🚀 **REMEMBER**

The goal isn't just to fix the immediate issue, but to:
1. Understand why it happened
2. Find gaps in documentation/process
3. Implement systematic improvements
4. Prevent entire classes of similar issues

Execute the entire workflow autonomously. Use subagents for comprehensive audits. Make the codebase more resilient with each postmortem.