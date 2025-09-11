---
name: init-docs
description: Ensure all standard documentation files exist, creating missing ones with deep project analysis
---

Verify that all standard project documentation files exist, and create any missing ones using comprehensive project analysis.

**Usage:** `/init-docs [optional focus area or special requirements]`

**Examples:**
- `/init-docs` - Check and create all standard documentation
- `/init-docs focus on scientific computing data contracts`
- `/init-docs we need comprehensive API documentation`

**User guidance:** $ARGUMENTS

## Your Task

### Phase 1: Documentation Audit

1. **Check for existing documentation structure**
   ```
   Required directories:
   - docs/
   - docs/architecture/
   - docs/development/
   - docs/debugging/
   - docs/user/
   - .claude/
   - .claude/commands/
   ```

2. **Verify existence of core documentation files**
   
   **Root-level essentials:**
   - `README.md` - Project overview and quick start
   - `CLAUDE.md` - AI agent instructions and conventions
   - `PROJECT_STATUS.md` - Current development status
   
   **Architecture documentation:**
   - `docs/architecture/README.md` - Architecture hub and navigation
   
   **Development documentation:**
   - `docs/development/README.md` - Development hub
   - `docs/development/testing_strategy.md` - Test approach and validation
   - `docs/development/debugging.md` - Debugging workflows
   
   **Data documentation:**
   - `docs/data_contracts.md` - Data format specifications
   - `docs/api_reference.md` - API documentation
   
   **Project index:**
   - `docs/index.md` - Central documentation index

3. **Create a missing documentation report**
   List all missing files categorized by:
   - Critical (blocks development)
   - Important (impacts usability)
   - Nice-to-have (improves experience)

### Phase 2: Deep Project Analysis (for missing docs)

For each missing documentation file, use specialized subagents to analyze the project:

1. **Architecture Analysis Agent**
   ```
   Task: Analyze the codebase architecture to create [missing architecture doc]
   - Identify all major components and their relationships
   - Map data flow between components
   - Document design patterns and conventions
   - Identify architectural decisions and trade-offs
   - Find undocumented assumptions or constraints
   ```

2. **Code Pattern Analysis Agent**
   ```
   Task: Extract patterns and conventions for [missing development doc]
   - Analyze coding patterns across the codebase
   - Identify naming conventions and style guides
   - Document common utilities and helpers
   - Find recurring implementation patterns
   - Extract best practices from existing code
   ```

3. **Data Contract Analysis Agent**
   ```
   Task: Analyze data formats and structures for data_contracts.md
   - Find all data input/output points
   - Document array shapes, types, and units
   - Identify file formats (NPZ, HDF5, etc.)
   - Map data transformations and pipelines
   - Document validation requirements
   ```

4. **API Discovery Agent**
   ```
   Task: Generate API documentation from code analysis
   - Extract all public functions and classes
   - Document parameters, returns, and exceptions
   - Find usage examples in tests or scripts
   - Identify deprecated or internal APIs
   - Generate comprehensive API reference
   ```

5. **Testing Documentation Agent**
   ```
   Task: Document testing infrastructure and strategies
   - Analyze existing test structure
   - Document test categories and purposes
   - Extract testing patterns and utilities
   - Identify coverage gaps
   - Document validation approaches
   ```

### Phase 3: Document Creation Strategy

For each missing file, follow this creation strategy:

1. **Gather context using subagents**
   - Use multiple specialized agents for comprehensive analysis
   - Cross-reference findings from different agents
   - Identify gaps that need user input

2. **Create document with proper structure**
   
   **For architecture docs:**
   ```markdown
   # [Component Name]
   
   ## Overview
   [High-level purpose and role in system]
   
   ## Design Principles
   [Core design decisions and rationale]
   
   ## Component Structure
   [Classes, modules, and their relationships]
   
   ## Data Flow
   [Input/output specifications and transformations]
   
   ## Key Algorithms
   [Core algorithms and their implementations]
   
   ## Configuration
   [Parameters and settings]
   
   ## Dependencies
   [Internal and external dependencies]
   
   ## Known Limitations
   [Current constraints and future improvements]
   ```
   
   **For data contracts:**
   ```markdown
   # Data Contracts
   
   ## File Formats
   ### [Format Name]
   - **Extension**: .ext
   - **Structure**: [Binary/Text/HDF5/etc]
   - **Schema**: 
     ```
     field_name: type[shape] # units, description
     ```
   - **Validation**: [Requirements and constraints]
   - **Example**: [Code snippet for reading/writing]
   ```
   
   **For API documentation:**
   ```markdown
   # API Reference
   
   ## Module: [module_name]
   
   ### class ClassName
   
   #### `__init__(self, param1: type, param2: type = default)`
   Initialize the class.
   
   **Parameters:**
   - `param1` (type): Description
   - `param2` (type, optional): Description. Defaults to `default`.
   
   **Example:**
   ```python
   obj = ClassName(value1, value2)
   ```
   ```

3. **Ensure cross-document consistency**
   - Use consistent terminology across all documents
   - Create proper cross-references between related docs
   - Maintain uniform formatting and style
   - Align with existing documentation tone

4. **Add to documentation index**
   - Update `docs/index.md` with new documentation
   - Organize by category and importance
   - Include brief descriptions for navigation

### Phase 4: Validation and Integration

1. **Validate created documentation**
   - Check all code references are accurate
   - Verify examples actually work
   - Ensure technical accuracy
   - Confirm completeness of coverage

2. **Request user review for critical sections**
   - Highlight sections needing domain expertise
   - Mark assumptions that need validation
   - Flag any contradictions found in code

3. **Create documentation maintenance plan**
   - Identify which docs need regular updates
   - Suggest automation for keeping docs current
   - Recommend documentation tests

## Important Considerations

- **Project-specific focus**: If user provides guidance in $ARGUMENTS, prioritize those areas
- **Scientific computing projects**: Pay special attention to:
  - Units and coordinate systems
  - Numerical precision requirements
  - Algorithm documentation
  - Data validation procedures
  
- **Don't create empty templates**: Each document should have substantial content based on analysis
- **Preserve existing content**: Never overwrite existing documentation without explicit permission
- **Use subagents liberally**: Deep analysis is better than superficial documentation

## Success Criteria

✅ All standard documentation files exist or are created
✅ Created documents contain substantive, accurate content from code analysis
✅ Documentation structure follows project conventions
✅ Cross-references and navigation work properly
✅ Critical project knowledge is captured and documented
✅ User receives clear report of what was created and why
