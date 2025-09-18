# Global Agent Defaults

This file sets personal defaults for how the agent should operate across projects.

## Trigger Phrases

- Scope: Trigger phrases apply only to the assistant’s next turn. They are single‑turn directives. If a subsequent user message does not include a trigger phrase, the assistant returns to default mode.

- "use web": When I say this, use the Playwright MCP web-browsing tools configured as `mcp_servers.playwright` to research or extract information. If no URL is given, ask for a URL or a short query and proceed. Prefer searching and reading pages; avoid logging into sites, submitting forms, or performing irreversible actions unless I explicitly ask.
  - Always summarize findings succinctly and include the source URLs.
  - Keep network usage minimal and relevant to the task.

- "use commit": Only commit when I explicitly say this. Until then, propose patches and show diffs without committing.
  - When I say "use commit", stage only files relevant to the task and ask for (or confirm) the commit message before committing.
  - Dont ask for confirmation if i say use commit you are free to commit
  - Never push unless I explicitly request it.

- "use img": When I say this, locate and use my latest screenshot from `~/Pictures/Screenshots`.
  - Determine the latest file by modification time among common image types (e.g., `*.png`, `*.jpg`, `*.jpeg`).

- "use plan only": Enter analysis-and-planning mode; only plan and run read-only commands. Do not edit files or perform write/destructive operations until I lift this mode.
  - Always maintain and update the plan (`update_plan`) while analyzing.
  - Allowed examples: `ls`, `cat`, `rg`, `git status`, `git diff`, `git log`, `docker compose ps`, `docker compose logs <service>`, `docker ps`, `docker inspect`.
  - Forbidden examples: `apply_patch`, `git add/commit/push`, package installs, modifying files, starting/stopping services, `docker compose build`, `docker compose up/down/restart`, `docker exec`, `kubectl apply/delete/exec/scale`.
  - If a command's effect is ambiguous, treat it as forbidden and ask first.

- "use event": Make an event-driven trigger using a single long-lived streaming command that self-terminates on the first match.
  - If details are missing, ask for: target pattern/regex, log source (e.g., `docker compose logs -f <service>`), and any context needed.
  - Prefer a one-shot stream that exits at first match over polling.

- "use wait nmw": Start a specified command and wait for it to exit, no matter how long it takes (NMW = No Matter What).
  - Confirm or estimate duration; set a large `timeout_ms` with buffer.
  - Capture both stdout and stderr to a `/tmp` log; parse afterward with `rg`/`sed`/`awk` based on the goal.
  - Treat a non-zero exit as a valid outcome; report status and findings explicitly.

- Explicit: "use tool <x> to <y>": When I explicitly instruct to use a tool (e.g., "use tool ssh to check host", "use tool docker compose to view logs"), assume the tool is installed and proceed to run it to perform the requested action.
  - Only two acceptable outcomes:
    - Tool executed and produced a result (success or actionable error output).
    - Tool invocation failed due to unavailability (e.g., `command not found`); then promptly ask me to verify installation, quoting the exact error seen.
  - Do not refuse or hesitate preemptively; attempt the command first. Skip preliminary `command -v` checks for explicitly requested tools.

- "go for it": Begin implementing immediately using any necessary tools and file edits to accomplish the agreed task. Do not hesitate or over-ask; act decisively within the discussed approach.
  - Use available tools and perform writes/edits as needed, respecting the current approval policy and sandbox constraints.
  - Still honor “No Unrelated Refactors” and avoid scope creep—do only what’s required to complete the task and its direct dependencies.
  - If an operation would be destructive or ambiguous, confirm briefly; otherwise proceed.

## Event-Driven Triggers

- Preferred: single streaming command that self-terminates
  - Run one long-lived command that follows logs and exits on the first matching line.
  - Example shell call:
    - command: ["bash","-lc","docker compose logs -f backend | grep -m1 -E '[Ee]rror.\*xyz'"]
    - timeout_ms: use a large value (e.g., `7_200_000` for 2 hours).
  - Rationale: streams output continuously and finishes exactly when the event appears, avoiding repeated "logs → sleep → logs".

- Parameters and safety
  - Always include a sufficiently large `timeout_ms` for long-running streams.
  - If the environment requires escalated permissions, set `with_escalated_permissions: true` and provide a short justification.
  - Respect the current approval policy and sandbox constraints.

- Matching tips
  - Use `grep -E` for regex and `-m1` to stop at the first match.
  - If binary data or color codes appear, add flags as needed:
    - `grep -a` to treat as text.
    - `grep --line-buffered` (when available) to reduce buffering.
  - Consider an `awk` alternative if `grep` options are unavailable:
    - command: ["bash","-lc","docker compose logs -f backend | awk '/[Ee]rror.\*xyz/ { print; exit }'"]

- Optional: interactive/attached sessions (if supported)
  - Start a single log-following session and monitor its output; terminate the session when the target event appears.
  - Use a single session rather than repeated invocations; send input (e.g., Ctrl-C) to end once the event is seen.

- Cancellation and cleanup
  - If the user interrupts, cleanly terminate the running command.
  - After completion, summarize the matched line and minimal surrounding context succinctly and include the command used.

## Long-Running Wait (NMW)

- Purpose and semantics
  - Run a command and wait until it exits (success or failure), no matter how long it takes.
  - Use when runtime is uncertain or long (e.g., `cargo run` potentially 30+ minutes).
  - The command’s non-zero exit does not mark the flow as failed; it’s reported.

- Inputs to confirm
  - Command: exact invocation (e.g., `cargo run --bin scan`).
  - Duration: user estimate, otherwise provide a cautious estimate and buffer.
  - Parsing goal: what to extract after completion (e.g., `document id: 123`, owner line).

- Duration and timeouts
  - Set `timeout_ms` ≥ estimated duration + generous buffer (e.g., 2× estimate, minimum 2 hours).
  - For unknown durations, default to a large window (e.g., 12 hours = `43_200_000`) and ask to confirm.
  - Respect approval policy and sandbox constraints.
  - If escalated permissions are needed, set `with_escalated_permissions: true` with a short justification.

- Execution pattern (robust)
  - Always capture both stdout and stderr; preserve exit code; record elapsed time.
  - Disable color for cleaner parsing when possible (e.g., `NO_COLOR=1`, `CARGO_TERM_COLOR=never`).
  - Use a unique `/tmp` filename:
    - `outfile=/tmp/<slug>-$(date +%s).log`
  - Example shell call:
    - command: ["bash","-lc","outfile=/tmp/scan-$(date +%s).log; start=$(date +%s); set -o pipefail; NO_COLOR=1 CARGO_TERM_COLOR=never cargo run --bin scan 2>&1 | tee \"$outfile\"; cmd_status=${PIPESTATUS[0]}; end=$(date +%s); echo \"EXIT_STATUS=$cmd_status\" | tee -a \"$outfile\"; echo \"ELAPSED_SECONDS=$((end-start))\" | tee -a \"$outfile\"; exit 0"]
    - timeout_ms: 43_200_000
  - Rationale: `set -o pipefail` preserves the command’s exit status; `2>&1` captures stderr; color disabled for reliable text parsing; we exit 0 so the tool call remains “successful” while status is recorded in the log.

- Handling large or noisy output
  - Prefer writing to a file via `tee`; avoid streaming huge logs in the console.
  - If ANSI codes still appear, strip during analysis: `sed -r 's/\x1B\[[0-9;]*[mK]//g'`.
  - Keep the raw log until analysis completes; compress or clean up afterward if requested.

- Post-run analysis (examples)
  - Find a document occurrence with context:
    - `rg -n -C2 -e 'document id:\s*123' \"$outfile\"`
  - Extract owner following the matched document line:
    - command: ["bash","-lc","awk '/document id: 123/ {found=1; next} found && /owner\s*:/ {print; exit}' \"$outfile\""]
  - If multiple matches are possible, report the first match and count of total matches; offer to refine the pattern.

- Reporting
  - Provide: command executed, `outfile` path, exit status (from log), elapsed time, and extracted findings (e.g., owner for doc 123).
  - If no match is found, state that clearly and propose next search patterns.

- Cancellation and cleanup
  - On user interrupt, terminate the process cleanly and keep the log.
  - Cleanup is opt-in; retain the `/tmp` log by default for audit/debug.

- Quick template
  - Inputs: command, estimate, goal pattern(s)
  - Run:
    - ["bash","-lc","outfile=/tmp/<slug>-$(date +%s).log; start=$(date +%s); set -o pipefail; NO_COLOR=1 <CMD> 2>&1 | tee \"$outfile\"; s=${PIPESTATUS[0]}; end=$(date +%s); echo EXIT_STATUS=$s | tee -a \"$outfile\"; echo ELAPSED_SECONDS=$((end-start)) | tee -a \"$outfile\"; exit 0"]
  - Parse: `rg -n -C2 '<pattern>' \"$outfile\"` then narrow with `awk`/`sed` as needed.

## Tool Preferences

- Prefer the Playwright MCP server for any web browsing, scraping, or page interaction. Do not use other web tools unless I ask or agree.

- MUI MCP (Material UI docs)
  - Use `mcp_servers.mui-mcp` to fetch authoritative Material UI documentation and examples when answering MUI-related questions.
  - Server: `npx -y @mui/mcp@latest` (stdio transport).
  - Prefer quoting and including source URLs returned by the server in summaries.
  - Reference: https://mui.com/material-ui/getting-started/mcp/

## Planning

- Always use the Codex CLI planning tool (`update_plan`) for every task.
- Initialize a plan before any tool calls or file edits.
- Maintain exactly one `in_progress` step at all times.
- Update the plan when starting/finishing a step, after notable actions, or if direction changes.
- Keep steps short (≤ 7 words), action-oriented, and easy to verify.
- Mark steps `completed` when done; close out all steps at task end.
- For trivial tasks, create a minimal single-step plan.

## Command Usage

- Use any command available in the environment without hesitation; do not hold back on safe, non-sudo commands.
- Never use `sudo`. It is unavailable and will hang the session; I would need to restart.
- If a needed command is missing, ask me to install it (installing typically requires sudo). Include the command name and suggested package when asking.
- If an operation requires `sudo`, ask me to run it and provide the exact command and paste back the full output. Include why it’s needed and the expected outcome.
- Prefer confirming availability with `command -v <cmd>` before relying on a tool, except when I explicitly say "use tool <x>"—in that case attempt immediate execution first and only fall back to asking if the command truly is missing.
- Respect active triggers: when "use plan only" is active, run only read-only commands per that section.

### Explicit Tool Invocation Guarantees

- Trust explicit directives: If I say "use tool X to do Y", run the tool to do Y.
- Acceptable outcomes are limited to:
  - Ran the tool and returned results (including stderr that informs next steps), or
  - Received a concrete unavailability error (e.g., `command not found`) and asked me to confirm installation, including the exact command and error text.
- Do not claim inability or lack of tool without first attempting execution.

## Attempt Before Refusal

- Never claim a tool/command “is not available” without first verifying and attempting a safe invocation.
  - Check presence: `command -v <cmd>` and/or `<cmd> --version/-V` when available.
  - If present, run a harmless or dry-run form to validate basic usability (e.g., `ssh -V`; for connectivity, `ssh -o BatchMode=yes -o ConnectTimeout=5 user@host 'true'`).
  - If the tool lacks a dry-run, prefer the minimal no-op that should succeed under constraints (no sudo, sandbox, approval policy).
  - On failure, report the exact command attempted, exit code, and a succinct stderr summary; then propose next steps.
  - Explicit-request exception: When I say "use tool <x>", skip pre-checks and attempt execution first; if and only if it errors as unavailable, ask me to verify installation.
- Do not assume unavailability due to missing context. If required details are absent (e.g., host, credentials), ask for them and propose the precise test command you will run once provided.
- Respect safety modes: under "use plan only", perform read-only checks (e.g., `command -v`, `--help`, `--version`) and avoid write/destructive attempts, but still do the verification before saying something cannot be used.
- Examples:
  - SSH: try `ssh -V`; if a host/user is provided, attempt a non-interactive `BatchMode` check; otherwise request host/user and key/password details.
  - CLIs: verify with `--version`/`--help`, then attempt a no-op subcommand if available.

## Scope Discipline (No Unrelated Refactors)

- Stay narrowly focused on the requested task: perform only what I asked, plus strictly necessary dependents/dependencies to keep the code building and the task working.
- Do not refactor, rewrite, or “improve” unrelated code, even if encountering `TODO`/`FIXME` notes or obviously suboptimal code.
- Allowed adjustments when required by the task:
  - Update signatures, imports, and direct call sites impacted by the requested change.
  - Make minimal edits to tests or configs directly exercising the changed behavior.
  - Add or update `.env` entries only when new configuration is introduced by the requested change.
- Prohibited without explicit request:
  - Drive-by cleanups, stylistic refactors, reorganizing files, or rewriting functions beyond what is necessary for the task to work.
  - Changing unrelated tests, renaming symbols or files unrelated to the requested change.
  - Implementing performance or architectural changes not directly required for the task.

## Command Notes

- Redis (`redis-cli`)
  - Use `redis-cli` for Redis interactions; prefer read-only calls when analyzing (e.g., `PING`, `INFO`, `SCAN` over `KEYS *`).
  - Find connection details in project config: `.env*`, `docker-compose*.yml`, Helm values, Kubernetes Secrets/ConfigMaps, or app config files. Decode k8s Secret data (base64).
  - Connect via host/port/password or container context (e.g., `docker compose exec <redis> redis-cli`). For clusters, include `-c`.
  - Avoid destructive commands (`FLUSHALL`, `DEL` patterns, `CONFIG SET`) unless explicitly requested.
  - When "use plan only" is active, only run read-only commands.

- Postgres (`psql`)
  - Use `psql` with a full URL when possible: `psql postgresql://user:pass@host:port/dbname`.
  - Discover credentials from `.env*`, `docker-compose*.yml`, Kubernetes manifests/secrets, or app config. Prefer env vars like `DATABASE_URL`.
  - Read-only checks: `\conninfo`, `SELECT 1;`, list tables with `\dt`, describe table with `\d <table>`.
  - Do not run migrations or DDL/DML without explicit approval.
- When "use plan only" is active, only run read-only queries and meta-commands.

## Environment (.env)

- Always keep `.env` up to date and in sync with variables used in the codebase.
- If code references an env var that is missing in `.env`, add it immediately with a safe default.
- Defaults and credentials: use real credentials when already present in context (provided by user, found in code, or existing in `.env`). If a credential is unknown, use a clear placeholder or safe local value. Default features to disabled/off; prefer least‑privilege, non‑destructive settings.
- Do not hesitate to read `.env`. Read it whenever needed to analyze, configure, or verify values.
- When introducing new configuration in code, ensure the corresponding `.env` entry exists at the same time.
- During analysis ("use plan only"), read `.env` and propose additions; avoid writing until changes are approved.
