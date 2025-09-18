#!/usr/bin/env python3
"""Send Codex CLI notifications to swaync via notify-send."""

from __future__ import annotations

import json
import shutil
import subprocess
import sys


def _get_field(payload: dict[str, object], *candidates: str) -> object | None:
    for key in candidates:
        if key in payload:
            return payload[key]
    return None


def _stringify(value: object) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (list, tuple)):
        return " \u2022 ".join(str(item) for item in value if item)
    return str(value)


def _truncate(text: str, limit: int = 240) -> str:
    text = text.strip()
    if len(text) <= limit:
        return text
    return text[: limit - 1].rstrip() + "\u2026"


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        print("Usage: codex_notify.py <NOTIFICATION_JSON>", file=sys.stderr)
        return 1

    raw = argv[1]
    try:
        payload = json.loads(raw)
    except json.JSONDecodeError:
        print("Invalid notification payload", file=sys.stderr)
        return 1

    notification_type = _get_field(payload, "type")
    if notification_type != "agent-turn-complete":
        return 0

    assistant_msg = _stringify(
        _get_field(payload, "last-assistant-message", "last_assistant_message")
    )
    input_msgs = _get_field(payload, "input_messages", "input-messages")
    body = _stringify(input_msgs)

    title = assistant_msg or "Codex: Turn Complete"
    body_text = body or ""

    title = _truncate(f"Codex: {title}" if not title.startswith("Codex:") else title, 120)
    body_text = _truncate(body_text, 280)

    if not shutil.which("notify-send"):
        print("notify-send not found; cannot display notification", file=sys.stderr)
        return 0

    args = [
        "notify-send",
        "-a",
        "Codex CLI",
        "-i",
        "dialog-information",
        title or "Codex",
    ]

    if body_text:
        args.append(body_text)

    try:
        subprocess.run(args, check=False)
    except OSError as exc:
        print(f"Failed to invoke notify-send: {exc}", file=sys.stderr)
        return 1

    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
