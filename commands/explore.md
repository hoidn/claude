### **Command: `/explore <topic>`**

**Goal:** To perform a comprehensive, multi-faceted exploration of a specified topic within the codebase and synthesize the findings into a structured, human-readable knowledge artifact. This command automates the cognitive-heavy lifting of "getting up to speed."

**Usage:**
*   `/explore ptycho/raw_data.py` (Topic: A specific file)
*   `/explore "the authentication workflow"` (Topic: A high-level concept)
*   `/explore plans/active/new-feature/plan.md` (Topic: A planning document)

**Flags:**
*   `--depth <shallow|deep>` (Default: `shallow`): Controls how many dependency levels to trace.
*   `--focus <api|data|performance>` (Default: `api`): Tailors the final report's emphasis.
*   `--output-format <summary|map|refsheet>` (Default: `summary`): Defines the structure of the final output.

---

## 🔴 **CRITICAL: MANDATORY EXECUTION FLOW**

**YOUR ROLE IS TO ORCHESTRATE A TWO-AGENT RESEARCH & SYNTHESIS RELAY.**
1.  You MUST parse the `<topic>` and any flags from the user's command.
2.  You MUST execute **Phase 1: Exploration** by invoking a "Researcher" sub-agent. This agent's sole purpose is to gather raw, relevant information from the entire codebase.
3.  You MUST take the structured output from the Researcher (the "Context Package") and use it as the *only* input for **Phase 2: Synthesis**.
4.  You MUST invoke a "Synthesizer" sub-agent to process the Context Package and generate the final, user-facing report.
5.  You MUST present the Synthesizer's final report to the user without modification.

**DO NOT:**
-   ❌ Answer the user's query with your own pre-existing knowledge. You must run the full two-phase workflow.
-   ❌ Blend the roles of the two agents. The Researcher only gathers; the Synthesizer only analyzes the gathered data.
-   ❌ Allow the Researcher to make any code changes. It is a read-only agent.

---

## 🤖 **AGENTIC WORKFLOW**

### **Phase 1: Exploration (The "Researcher" Agent)**

**Input:** `<topic>`, `--depth` flag
**Goal:** To find and extract every piece of relevant information about the topic from the codebase and package it for the next phase.

| ID | Task Description | State | How/Why & API Guidance |
| :-- | :--- | :--- | :--- |
| 1.A | **Keyword & Seed Path Identification** | `[ ]` | **Why:** To create initial search terms from the user's topic. <br> **How:** Analyze the `<topic>`. If it's a file path, that's your primary seed. If it's a concept (e.g., "authentication"), derive keywords like `auth`, `login`, `token`, `jwt`, `user`. |
| 1.B | **Multi-Vector Information Gathering** | `[ ]` | **Why:** To build a complete picture by searching across different types of project artifacts. <br> **How:** Systematically perform the following searches using your keywords and seed paths: <br> 1.  **Code Search (`grep`):** Find all occurrences of keywords in source code (`.py`, `.sh`). <br> 2.  **Documentation Search (`grep`):** Find all occurrences in documentation (`.md`). <br> 3.  **Test Search (`grep`):** Find all relevant tests (`test_*.py`) to understand usage and expected behavior. <br> 4.  **Dependency Analysis (`pydeps` or similar):** If the topic is a file, find all files that import it (consumers) and all files it imports (dependencies). Trace this to the level specified by `--depth`. |
| 1.C | **Context Package Assembly** | `[ ]` | **Why:** To create a structured, self-contained bundle of raw information for the Synthesizer agent. <br> **Output:** A single structured data object (e.g., JSON or XML) containing: <br> - `topic`: The original user query. <br> - `primary_files`: A list of file paths that are *directly* related. <br> - `related_files`: A list of consumers, dependencies, and relevant test files. <br> - `code_snippets`: A collection of the most relevant functions or classes found. <br> - `doc_excerpts`: Key paragraphs or sections from documentation. <br> - `test_examples`: The most illustrative test cases showing usage. |

### **Phase 2: Synthesis (The "Synthesizer" Agent)**

**Input:** The "Context Package" from Phase 1, `--focus` flag, `--output-format` flag.
**Goal:** To transform the raw information from the Context Package into a clean, insightful, and human-readable knowledge artifact.

| ID | Task Description | State | How/Why & API Guidance |
| :-- | :--- | :--- | :--- |
| 2.A | **Context Assimilation** | `[ ]` | **Why:** To build a complete mental model before writing. <br> **How:** Read the *entire* Context Package. Cross-reference the code snippets with the documentation excerpts and test examples to understand the relationships between them. |
| 2.B | **Focused Analysis** | `[ ]` | **Why:** To tailor the output to the user's specific interest. <br> **How:** Re-analyze the assimilated context through the lens of the `--focus` flag. <br> - **If `api`:** Focus on function signatures, parameters, return values, and usage patterns in tests. <br> - **If `data`:** Focus on data structures, array shapes, and transformations between components. <br> - **If `performance`:** Look for loops, I/O operations, and comments mentioning optimization or bottlenecks. |
| 2.C | **Artifact Generation** | `[ ]` | **Why:** To create the final, polished report in the user-requested format. <br> **How:** Generate a Markdown report using the template corresponding to the `--output-format` flag (see templates below). You must populate the template using *only* the information from the Context Package. |

---

## 템플릿 & 가이드라인 (Templates & Guidelines)

### **Output Template: `summary` (Default)**
```markdown
# Exploration Summary: <Topic>

### TL;DR
[A concise, 2-3 sentence summary of the component's purpose and role in the system.]

### Architectural Role
[A more detailed explanation of how this component fits into the broader architecture. What problem does it solve? Who are its primary consumers?]

### Key Responsibilities
- **Responsibility 1:** [e.g., Parses raw NPZ files and enforces physical coherence.]
- **Responsibility 2:** [e.g., Groups scan points into batches based on the global `gridsize` parameter.]
- **Responsibility 3:** [e.g., Caches grouping calculations to accelerate subsequent runs.]

### Critical Dependencies & Interactions
- **Consumes Data From:** [List sources, e.g., Raw `.npz` files on disk]
- **Produces Data For:** `ptycho/loader.py`
- **Depends On:** `ptycho/params` (for global state), `ptycho/config/config.py`
- **Key Interaction:** The behavior of `generate_grouped_data()` is fundamentally altered by the value of `params.get('gridsize')`, switching between two different algorithms.

### Open Questions / Points of Interest
- [Highlight any surprising findings, potential risks, or areas for future investigation, e.g., "The dependency on global state makes this module difficult to test in isolation."]
```

### **Output Template: `map`**
```markdown
# Component Map: <Topic>

### Data Flow Diagram
\`\`\`mermaid
graph TD
    A[Source: .npz file on Disk] --> B(Component: ptycho/raw_data.py);
    C[Global State: ptycho/params] --> B;
    B --> D{Output: Grouped Data Dictionary};
    D --> E[Consumer: ptycho/loader.py];
\`\`\`

### Key Function Trace
*File: `ptycho/raw_data.py`*
- **`RawData.__init__(...)`**: Loads coordinates and diffraction patterns.
- **`RawData.generate_grouped_data(...)`**: **(Primary public API)**
  - Calls `_get_groups_from_cache_or_recompute()` to manage caching.
  - **If `gridsize > 1`**: Calls `_group_then_sample()` which implements the robust grouping logic.
  - **If `gridsize == 1`**: Performs a simple sequential slice.

*File: `ptycho/loader.py`*
- **`Loader.load_data()`**:
  - Instantiates `RawData`.
  - Calls `raw_data.generate_grouped_data()` to get the input for the ML model.
```

### **Output Template: `refsheet`**
```markdown
# Quick Reference: <Topic>

### `ptycho/raw_data.py`

**Purpose:** The primary data ingestion and scan-point grouping layer. Translates raw file data into model-ready batches.

---
#### **Class: `RawData`**
*   **`__init__(self, xcoords, ycoords, diffraction, ...)`**
    *   **Description:** Initializes the object with raw data arrays.
    *   **Parameters:**
        *   `xcoords` (`np.array`): Shape `(num_scans,)`. X-coordinates of scan positions.
        *   `diffraction` (`np.array`): Shape `(num_scans, N, N)`. Diffraction patterns.
---
#### **Method: `RawData.generate_grouped_data`**
*   **`generate_grouped_data(self, N, K=4, nsamples=1, ...)`**
    *   **Description:** The core public API. Samples and groups scan points into a dictionary of tensors. Behavior is critically dependent on global state.
    *   **Parameters:**
        *   `nsamples` (`int`): The number of samples (if gridsize=1) or groups (if gridsize>1) to generate.
    *   **Returns:** `dict`: A dictionary of NumPy arrays ready for the data loader.
    *   **Usage Example:**
        \`\`\`python
        # Assumes 'raw_data' is an instantiated RawData object
        # and 'params' is the global state manager.
        params.set('gridsize', 2)
        grouped_data = raw_data.generate_grouped_data(N=64, nsamples=1000)
        # grouped_data['X'].shape will be (1000, 64, 64, 4)
        \`\`\`
```
