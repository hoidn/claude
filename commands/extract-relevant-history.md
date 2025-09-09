# Command: /extract-relevant-history

**Goal:** Intelligently review all existing session summaries and extract only the parts relevant to the current task, providing focused historical context without information overload.

**Context:** This command delegates to a general-purpose subagent that understands the main agent's current focus and filters historical documentation accordingly.

**Execution Steps:**

1. **Current Context Analysis**
   - Analyze the last 5-10 messages to understand current task/focus
   - Identify key components, files, features being worked on
   - Extract technical keywords, error patterns, or problem domains
   - Note any specific technologies or libraries in use

2. **Smart History Search**
   - Read all files under `history/` directory
   - Score each session's relevance based on:
     * Keyword matches with current context
     * File/component overlap
     * Technical similarity (same libraries, patterns)
     * Problem domain alignment
     * Temporal relevance (related recent work)

3. **Intelligent Extraction**
   - From highly relevant sessions (score > 70%):
     * Extract complete relevant sections
     * Include problem solutions that might apply
     * Pull implementation patterns used
   - From moderately relevant sessions (score 40-70%):
     * Extract specific paragraphs or code blocks
     * Focus on lessons learned or gotchas
   - From tangentially relevant sessions (score 20-40%):
     * Extract only critical warnings or decisions

4. **Contextual Organization**
   - Group extracts by relevance type:
     * **Direct Prerequisites**: Work this task builds upon
     * **Similar Problems**: Past solutions to comparable issues
     * **Technical Patterns**: Relevant implementation approaches
     * **Warnings/Gotchas**: Things to avoid based on past experience
     * **Related Decisions**: Architectural or design choices that affect current work

5. **Synthesis and Presentation**
   - Create a focused summary with:
     * Brief overview of found relevant history
     * Extracted content organized by relevance
     * Links to full sessions for deeper exploration
     * Key takeaways that apply to current task

**Expected Output:**
```markdown
## Relevant Historical Context

### Current Task Understanding
[Brief description of what the subagent identified as the current focus]

### Directly Related Work
- **[Session Date - Title](./session.md)**: [Relevant excerpt]
  - Key insight: [Specific applicable learning]

### Similar Problems Solved
- **[Session Date - Title](./session.md)**: [Solution approach]

### Important Warnings
- **[Session Date - Title](./session.md)**: [Gotcha to avoid]

### Recommended Reading Priority
1. [Most relevant session] - Critical for current task
2. [Second most relevant] - Contains useful patterns
3. [Third relevant] - Background context

Usage Examples:
/extract-relevant-history
/extract-relevant-history focus:authentication
/extract-relevant-history component:database exclude:testing
/extract-relevant-history last:7days

Customization Options:
- focus:[topic] - Explicitly specify area of interest
- component:[name] - Target specific component history
- exclude:[topic] - Filter out certain topics
- last:[timeframe] - Limit to recent history
- depth:[shallow|normal|deep] - Control extraction detail level

Subagent Instructions:
"Use your understanding of the current conversation context to identify and extract only the most relevant portions of historical session summaries. Focus on actionable insights, applicable solutions,
and important warnings that directly relate to what's being worked on now. Avoid overwhelming with unnecessary historical detail - be selective and purposeful in your extractions."

This slash command creates a smart, context-aware history review that:
- Automatically understands current context
- Filters noise from historical data
- Provides actionable insights
- Maintains links for deeper exploration when needed

