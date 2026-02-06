# Global Agent Defaults

This file sets personal defaults for how the agent should operate across projects.

## Trigger Phrases

- Scope: Trigger phrases apply only to the assistant’s next turn. They are single‑turn directives. If a subsequent user message does not include a trigger phrase, the assistant returns to default mode.

- "use commit": Only commit when I explicitly say this. Until then, propose patches and show diffs without committing.
  - When I say "use commit", stage only files relevant to the task and ask for (or confirm) the commit message before committing.
  - Dont ask for confirmation if i say use commit you are free to commit

- "use commit deploy": Commit, push, then deploy.
  - After committing, push the current branch, SSH to the target server, `cd` into the project, `git pull`, then run the project deployment pipeline (usually `docker compose up -d --build` for one or many affected services).
  - Ask for (or confirm) the commit message before committing, unless I include "use commit deploy no ask".

- "use commit deploy no ask": Same as "use commit deploy", but for the entire session.
  - After this trigger, for the rest of the session, whenever you make changes, commit, push, SSH/pull, and run the deployment pipeline without asking for a commit message.

- "use plan only": Enter analysis-and-planning mode; only plan and run read-only commands. Do not edit files or perform write/destructive operations until I lift this mode.
  - Always maintain and update the plan (`update_plan`) while analyzing.
  - Allowed examples: `ls`, `cat`, `rg`, `git status`, `git diff`, `git log`, `docker compose ps`, `docker compose logs <service>`, `docker ps`, `docker inspect`.
  - Forbidden examples: `apply_patch`, `git add/commit/push`, package installs, modifying files, starting/stopping services, `docker compose build`, `docker compose up/down/restart`, `docker exec`, `kubectl apply/delete/exec/scale`.
  - If a command's effect is ambiguous, treat it as forbidden and ask first.

- Explicit: "use tool <x> to <y>": When I explicitly instruct to use a tool (e.g., "use tool ssh to check host", "use tool docker compose to view logs"), assume the tool is installed and proceed to run it to perform the requested action.
  - Only two acceptable outcomes:
    - Tool executed and produced a result (success or actionable error output).
    - Tool invocation failed due to unavailability (e.g., `command not found`); then promptly ask me to verify installation, quoting the exact error seen.
  - Do not refuse or hesitate preemptively; attempt the command first. Skip preliminary `command -v` checks for explicitly requested tools.

- "go for it": Begin implementing immediately using any necessary tools and file edits to accomplish the agreed task. Do not hesitate or over-ask; act decisively within the discussed approach.
  - Use available tools and perform writes/edits as needed, respecting the current approval policy and sandbox constraints.
  - Still honor “No Unrelated Refactors” and avoid scope creep—do only what’s required to complete the task and its direct dependencies.
  - If an operation would be destructive or ambiguous, confirm briefly; otherwise proceed.

## SSH Conventions

- When I say to SSH into a server and run commands, assume the project is a git clone under `$HOME`.
- After connecting, `cd <project_name_we_are_working_on>` before running the requested commands.
- If that fails, use `ls`, `pwd`, and `cd` to locate the correct project directory and proceed.

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

## Configuration & Secrets

- Always keep configuration and secrets in git up to date. We use a self‑hosted GitLab, so it is safe and expected to commit required secrets (e.g., `.env`, service account JSON, config files) so they are not lost.
- If a required config/secret file is missing from git, warn me and suggest committing it and/or adjusting `.gitignore`.
- Keep `.env` in sync with variables used in the codebase.
- If code references an env var that is missing in `.env`, add it immediately with a safe default.
- Defaults and credentials: use real credentials when already present in context (provided by user, found in code, or existing in `.env`). If a credential is unknown, use a clear placeholder or safe local value. Default features to disabled/off; prefer least‑privilege, non‑destructive settings.
- Do not hesitate to read `.env`. Read it whenever needed to analyze, configure, or verify values.
- When introducing new configuration in code, ensure the corresponding `.env` entry exists at the same time.
- During analysis ("use plan only"), read `.env` and propose additions; avoid writing until changes are approved.
