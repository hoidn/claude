# Command: /session-summary

**Goal:** Generate a comprehensive session summary with bidirectional cross-references to all related session histories, creating a fully interconnected documentation network.

**Context:** This command delegates to a general-purpose subagent to analyze the current session, identify relationships with existing documentation, and create/update markdown files with proper
cross-referencing.

**Execution Steps:**

1. **Session Analysis**
   - Extract key accomplishments, changes, problems solved, and decisions made
   - Identify technologies, libraries, and tools used
   - Document unresolved issues and next steps

2. **Historical Context Discovery**
   - Search and read all files under `history/` directory
   - Identify related sessions by topic, feature, or component
   - Find dependency chains and affected areas

3. **Document Creation**
   - Generate `history/YYYY-MM-DD_[descriptive-topic-name].md`
   - Include metadata header with session type, related features, and follow-up requirements
   - Write detailed technical narrative with code examples

4. **Bidirectional Linking**
   - Add "Related Sessions" section in new summary
   - Update existing summaries with forward references
   - Use relative markdown links for navigation

5. **Quality Assurance**
   - Verify all cross-references are valid
   - Ensure technical details are comprehensive
   - Confirm context and rationale are documented

**Expected Output:**
- New session summary file created
- List of updated existing files with cross-references
- Relationship map showing session connections

**Usage Example:**
/session-summary

**Customization Options:**
- Add specific topics to emphasize: `/session-summary focus:performance-optimization`
- Link to specific sessions: `/session-summary related:2025-01-08_bug-fix.md`
- Set session type: `/session-summary type:refactoring`

