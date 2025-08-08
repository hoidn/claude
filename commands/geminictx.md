# Command: /geminictx [query]

**Goal:** Leverage a two-pass AI workflow to provide a comprehensive, context-aware answer to a user's query about the codebase. Pass 1 uses Gemini to identify relevant files, and Pass 2 uses your own (Claude's) synthesis capabilities on the full content of those files.

**Usage:**
- `/geminictx "how does authentication work?"`
- `/geminictx "explain the data loading pipeline"`

---

## 🔴 **CRITICAL: MANDATORY EXECUTION FLOW**

**This command follows a deliberate, non-negotiable two-pass workflow:**
1.  **Context Aggregation:** You MUST first run `repomix` to create a complete snapshot of the codebase.
2.  **Pass 1 (Gemini as Context Locator):** You MUST build a structured prompt file and execute `gemini -p` to identify a list of relevant files based on the user's query and the `repomix` context.
3.  **Pass 2 (Claude as Synthesizer):** You MUST then read the full content of EVERY file Gemini identified to build your own deep context before providing a synthesized answer.

**DO NOT:**
-   ❌ Skip the `repomix` step. The entire workflow depends on this complete context.
-   ❌ Guess which files are relevant. You must delegate this to Gemini.
-   ❌ Only read Gemini's one-sentence justifications. You must read the **full file contents**.
-   ❌ Answer the user's query before you have completed Pass 1 and read all identified files in Pass 2.

---

## 🤖 **YOUR EXECUTION WORKFLOW**

### Step 1: Gather Codebase Context with Repomix

First, create a comprehensive and reliable context snapshot of the entire project.

```bash
# The user's query is passed as $ARGUMENTS
USER_QUERY="$ARGUMENTS"

# Use repomix for a complete, single-file context snapshot.
# This is more robust than a long list of @-references.
# TODO: manually removing gemini-pass1-prompt.md is a temporary hack; we should have a principled way to exclude big .md files.
rm gemini-pass1-prompt.md; npx repomix@latest . --top-files-len 20 --include "**/*.{js,py,md,sh,json,c,h}" --ignore "build/**,node_modules/**,dist/**,*.lock,.claude/**,PtychoNN/**,torch/**"

# Verify that the context was created successfully.
if [ ! -s ./repomix-output.xml ]; then
    echo "❌ ERROR: Repomix failed to generate the codebase context. Aborting."
    exit 1
fi

echo "✅ Codebase context aggregated into repomix-output.xml."
```

### Step 2: Build and Execute Pass 1 (Gemini as Context Locator)

Now, build a structured prompt in a file to ask Gemini to find the relevant files.

#### Step 2.1: Build the Prompt File
```bash
# Clean start for the prompt file
rm -f ./gemini-pass1-prompt.md 2>/dev/null

# Create the structured prompt using the v3.0 XML pattern
cat > ./gemini-pass1-prompt.md << 'PROMPT'
<task>
You are an expert scientist and staff level engineer. Your sole purpose is to analyze the provided codebase context and identify the most relevant files for answering the user's query. Do not answer the query yourself.

<steps>
<0>
Given the codebase context in `<codebase_context>`,
in a <scratchpad>, list the paths of:
 - all source code files
 - all documentation files (all .md files that document the project's architecture and design, but not one-off files like session summaries)
 - all test files
 - all configuration files
 - all other relevant files
 </0>

<1>
Analyze the user's `<query>`.
REVIEW PROJECT DOCUMENTATION
 - **Read CLAUDE.md thoroughly** - This contains essential project context, architecture, and known patterns
 - **Read DEVELOPER_GUIDE.md carefully** - This explains the development workflow, common issues, and debugging approaches
 - Review all architecture.md and all other high-level architecture documents
 - **Understand the project structure** from these documents before diving into the code
</1>
<2>
Think about the <query> and analyze the codebase to form a full understanding of it. Once you are confident in your understanding, review the `<codebase_context>` again to identify all files (source code, documentation, configs) that might be relevant to the query (if in doubt, err on the side of including more files).
</2>
<3>
For each relevant file you identify, provide your output in the strict format specified in `<output_format>`.
</3>
</steps>

<context>
<query>
[Placeholder for the user's query]
</query>

<codebase_context>
<!-- Placeholder for content from repomix-output.xml -->
</codebase_context>
</context>

<output_format>
Your output must contain two sections:
Section 1: A detailed analysis of all data flows, transformations, and component interactions relevant to the query. 
Include mathematical formulas and diagrams where appropriate.

Section 2:
A list of entries. Each entry MUST follow this exact format, ending with three dashes on a new line.

FILE: [exact/path/to/file.ext]
RELEVANCE: [A concise, one-sentence explanation of why this file is relevant.]
SCORE: [A numeric score from 0.4 to 10.0, where 10 is the most relevant.]
---

Do not include any other text, conversation, or summaries in your response. Do 
not use tools. Your job is to do analysis, not an intervention
</output_format>
</task>
PROMPT
```

#### Step 2.2: Append Dynamic Context (Corrected Logic)
```bash
# This script injects the dynamic content into the prompt template using
# idempotent `sed` commands to prevent context duplication bugs.

# Inject the user's query by replacing its placeholder.
# Using a temp file handles special characters and multi-line input safely.
echo "$USER_QUERY" > ./tmp/user_query.txt
sed -i.bak -e '/\[Placeholder for the user.s query\]/r ./tmp/user_query.txt' -e '//d' ./gemini-pass1-prompt.md

# **CRITICAL FIX:** Atomically replace the codebase context placeholder.
# This robust method prevents the repomix output from being appended multiple
# times if the command is re-run or misinterpreted by the agent.
sed -i.bak -e '/<!-- Placeholder for content from repomix-output.xml -->/r ./repomix-output.xml' -e '//d' ./gemini-pass1-prompt.md

# Clean up backup files created by sed
rm -f ./gemini-pass1-prompt.md.bak

echo "✅ Built structured prompt for Pass 1: ./gemini-pass1-prompt.md"
```

#### Step 2.3: Execute Gemini
IMPORTANT: do NOT use a timeout for the gemini command. Gemini may need more than 1 minute to process the large context.
```bash
# Execute Gemini with the single, clean prompt file.
gemini -p "@./gemini-pass1-prompt.md > ./tmp/gemini-pass1-response.txt"
```

### Step 3: Process Gemini's Response & Prepare for Pass 2

After receiving the list of files from Gemini, parse the output and prepare to read the files.

```bash
# [You will receive Gemini's response, e.g., captured in $GEMINI_RESPONSE]

# Parse the output to get a clean list of file paths.
# This is a robust way to extract just the file paths for the next step.
FILE_LIST=$(echo "$GEMINI_RESPONSE" | grep '^FILE: ' | sed 's/^FILE: //')

# Verify that Gemini returned relevant files.
if [ -z "$FILE_LIST" ]; then
    echo "⚠️ Gemini did not identify any specific files for your query. I will attempt to answer based on general project knowledge, but the answer may be incomplete."
    exit 0
fi

echo "Gemini identified the following relevant files:"
echo "$FILE_LIST"
```

### Step 4: Execute Pass 2 (Claude as Synthesizer)

This is your primary role. Read the full content of the identified files to build deep context.

```bash
# Announce what you are doing for transparency.
echo "Now reading the full content of each identified file to build a deep understanding..."

# You will now iterate through the FILE_LIST and read each one.
# For each file in FILE_LIST:
#   - Verify the file exists (e.g., if [ -f "$file" ]; then ...).
#   - Read its full content into your working memory.
#   - Announce: "Reading: `path/to/file.ext`..."

# After reading all files, you are ready to synthesize the answer.
```

### Step 5: Present Your Synthesized Analysis

Your final output to the user should follow this well-structured format.

```markdown
Based on your query, Gemini identified the following key files, which I have now read and analyzed in their entirety:

-   `path/to/relevant/file1.ext`
-   `path/to/relevant/file2.ext`
-   `docs/relevant_guide.md`

Here is a synthesized analysis of how they work together to address your question.

### Summary
[Provide a 2-3 sentence, high-level answer to the user's query based on your comprehensive analysis of the files.]

### Detailed Breakdown

#### **Core Logic in `path/to/relevant/file1.ext`**
[Explain the role of this file. Reference specific functions or classes you have read.]

**Key Code Snippet:**
\`\`\`[language]
[Quote a critical code block from the file that you have read.]
\`\`\`

#### **Workflow Orchestration in `path/to/relevant/file2.ext`**
[Explain how this file uses or connects to the core logic from the first file.]

**Key Code Snippet:**
\`\`\`[language]
[Quote a relevant snippet showing the interaction.]
\`\`\`

### How It All Connects
[Provide a brief narrative explaining the data flow or call chain between the identified components.]

### Conclusion
[End with a concluding thought or a question to guide the user's next step.]
```

---
### Design Rationale & Best Practices

The logic in **Step 2.2** was specifically updated to use `sed` for injecting the `repomix` context. The previous method of using `echo ... >>` and `cat ... >>` was not **idempotent**, meaning running it multiple times would append the context repeatedly, leading to a corrupted prompt.

The corrected `sed -i.bak -e '/<placeholder>/r <file>' -e '//d' <prompt_file>` pattern is the standard for this project because:
1.  **It is atomic:** It finds and replaces the placeholder in one operation.
2.  **It is idempotent:** If the command is run again, the placeholder no longer exists, so no further changes are made.
3.  **It is unambiguous:** It provides a single, clear instruction to the agent, reducing the chance of misinterpretation.
