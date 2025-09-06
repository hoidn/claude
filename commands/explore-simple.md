
**Goal:** Comprehensive exploration of a codebase topic via two-agent research relay.

**Usage:** `/explore ptycho/raw_data.py` | `/explore "authentication workflow"`

**Flags:**
- `--depth <shallow|deep>`: Dependency trace depth
- `--focus <api|data|performance>`: Report emphasis  
- `--output-format <summary|map|refsheet>`: Output structure

## Workflow

### Phase 1: Research Agent
Gathers all relevant information about the topic:
- Extracts keywords and identifies seed paths
- Searches code, docs, tests, and dependencies
- Packages findings into structured Context Package

### Phase 2: Synthesizer Agent  
Transforms Context Package into final report:
- Assimilates all gathered information
- Applies focus lens (api/data/performance)
- Generates report in requested format

## Output Formats

**Summary** (default): Architectural role, responsibilities, dependencies
**Map**: Visual data flow + function trace
**Refsheet**: Quick API reference with examples

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
