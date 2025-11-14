  Task: Using parallel subagents (one per missing role×iteration), generate markdown summaries for only the last 30 iterations that lack summaries, then interleave them. Do not write or propose any helper
  scripts; use native LLM summarization in subagents and the file write tool only.

  Inputs:

  - BRANCH_PREFIX: <your branch, e.g., integration>
  - COUNT: 30
  - ROLES: galph, ralph
  - MAX_CONCURRENCY: 30

  Rules:

  - Absolutely no Python/Shell helper scripts or programmatic batching. If you start to write code, stop and ask me.
  - Use parallel subagents: each subagent receives exactly one raw log file (role+iteration) and the naming conventions below, and outputs a single markdown file. Limit to MAX_CONCURRENCY workers.
  - Be idempotent: never overwrite an existing summary; skip if present.
  - Use UTC timestamps and exact naming conventions.

  Discovery:

  - Build the union of iteration numbers from raw logs:
      - logs/<BRANCH_PREFIX>/galph/iter-*.log
      - logs/<BRANCH_PREFIX>/ralph/iter-*.log
  - Sort numerically and take the last COUNT (30).
  - For each role×iteration in that set, if a summary exists under:
      - logs/<BRANCH_PREFIX>/galph-summaries/iter-*-summary.md (galph)
      - logs/<BRANCH_PREFIX>/ralph-summaries/iter-*-summary.md (ralph)
        and matches the iteration number, skip. Otherwise, generate.

  Naming/paths:

  - Directories:
      - logs/<BRANCH_PREFIX>/galph-summaries/
      - logs/<BRANCH_PREFIX>/ralph-summaries/
  - Filename pattern (exact):
      - iter-<NNNNN>_<YYYYMMDD_HHMMSS>-summary.md
      - <NNNNN> = zero‑padded 5‑digit iteration (e.g., 00041)
      - Timestamp = current UTC at write time
      - Suffix must be -summary.md
  - If present, follow docs/logging/log_summary_conventions.md; otherwise, follow the above.

  Subagent work spec (per item):

  - Inputs: the single raw log file for that role×iteration + the naming conventions above.
  - Output file: as per pattern into the correct <role>-summaries directory; create the directory if missing; do not overwrite.
  - Content (markdown, concise and factual):
      - Summary
      - Key Actions
      - Decisions/Rationales
      - Errors/Failures and suspected root causes
      - Evidence/Links (repo-relative paths)
      - Next Steps
  - Style: neutral, no speculation, cite concrete evidence from the log. You may quote small excerpts. Do not include unrelated content.

  Execution:

  - Coordinate subagents up to MAX_CONCURRENCY. Ensure no two subagents handle the same role×iteration.
  - After all subagents finish, list:
      - Created files (with role, iter, path)
      - Skipped items (already existed)
      - Totals: created vs skipped

  Interleave (post-step):

  - Run: python -m scripts.orchestration.tail_interleave_logs <BRANCH_PREFIX> -n 30 --source summaries
  - If the module form fails, fallback: python scripts/orchestration/tail_interleave_logs.py <BRANCH_PREFIX> -n 30 --source summaries
  - Show the first ~40 lines of output for verification.

  Edge cases:

  - If multiple branch prefixes exist under logs/, ask me to pick one.
  - If a raw log is missing for a role×iteration, skip generating that specific summary and report it.
  - If a summary already exists for an iteration (for that role), do not regenerate.

  Deliverables:

  - Created/Skipped counts and file list.
  - The exact interleaver command used.
  - A short snippet (first ~40 lines) of the interleaved output.

