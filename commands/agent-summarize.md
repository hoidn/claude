Task: Generate missing markdown summaries for the last 30 iterations and interleave them.

  - Parameters:
      - BRANCH_PREFIX: <fill in, e.g., feature-torchapi>
      - COUNT: 30
      - ROLES: galph, ralph
      - MAX_CONCURRENCY: 8

  Instructions:

  - Input discovery:
      - Determine recent iterations by scanning raw logs under logs/<BRANCH_PREFIX>/galph/iter-*.log and logs/<BRANCH_PREFIX>/ralph/iter-*.log. Use the union of iteration numbers matched by
        ^iter-(\d+)_.*\.log$, sort numerically, and take the last COUNT (30).
      - For each role and each of those iterations, check for an existing summary in logs/<BRANCH_PREFIX>/<role>-summaries/ that matches ^iter-(\d+)_.*-summary\.md$. If a summary exists for that role+iter,
        skip it.
  - Output path and naming:
      - For each missing summary, write a file to:
          - logs/<BRANCH_PREFIX>/galph-summaries/iter-<NNNNN>_<YYYYMMDD_HHMMSS>-summary.md (for galph)
          - logs/<BRANCH_PREFIX>/ralph-summaries/iter-<NNNNN>_<YYYYMMDD_HHMMSS>-summary.md (for ralph)
      - Conventions:
          - <NNNNN> is the zero‑padded 5‑digit iteration (e.g., 00041).
          - Timestamp is UTC in YYYYMMDD_HHMMSS at the time of writing.
          - Keep the -summary.md suffix exactly.
          - Create the <role>-summaries directory if missing. Never overwrite existing files (idempotent).
  - Summary content (Markdown):
      - Keep it concise and factual for that single iteration. Include:
          - Summary
          - Key Actions
          - Decisions/Rationales
          - Errors/Failures (with suspected root causes)
          - Evidence/Links (repo‑relative paths)
          - Next Steps
      - Prefer direct quotes or pointers to the raw log where helpful. Avoid speculation.
  - Parallelization:
      - Use parallel subagents to generate summaries concurrently (one worker per missing role×iteration), up to MAX_CONCURRENCY (e.g., 8). Ensure each worker writes a unique file; never race on the same
        role×iter.
  - Post‑step (interleave summaries):
      - After all summaries are written, run:
          - python -m scripts.orchestration.tail_interleave_logs <BRANCH_PREFIX> -n 30 --source summaries
          - If the module form fails, fallback: python scripts/orchestration/tail_interleave_logs.py <BRANCH_PREFIX> -n 30 --source summaries
      - Print the first ~40 lines of the interleaved output for verification.
  - Deliverables:
      - List of created files with role, iter, and full path.
      - Counts: created vs skipped (already existed).
      - Interleaver command used and a short snippet of its output.
  - Constraints:
      - Use only repository files and UTC timestamps.
      - Do not modify existing summaries or raw logs.
      - Be fully idempotent and safe to re‑run.

