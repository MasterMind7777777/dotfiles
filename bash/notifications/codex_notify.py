#!/usr/bin/env python3
"""Codex → swaync notifier with custom sound + ntfy push.

Adds optional posting to an ntfy topic, configurable via env vars:

- NTFY_URL (default: http://192.168.0.92:2586)
- NTFY_TOPIC (default: codex)
- NTFY_ENABLED (default: 1)

If enabled and reachable, the script will HTTP POST the composed title/body
to the topic in addition to the local desktop notification.
"""

from __future__ import annotations

import json
import math
import os
import shutil
import struct
import subprocess
import sys
import wave
from datetime import datetime
from pathlib import Path
from urllib import request, error as urlerror


CACHE_DIR = Path.home() / ".cache" / "codex"
LOG_PATH = CACHE_DIR / "notify.log"
DOWNLOAD_SOUND = Path.home() / "Downloads" / "single-sound-message-icq-ooh.mp3"
SOUND_PATH = CACHE_DIR / DOWNLOAD_SOUND.name
BEEP_PATH = CACHE_DIR / "notify-beep.wav"

APP_NAME = "Codex CLI"
APP_ICON = "dialog-information"
EXPIRE_TIMEOUT_MS = 10000

# ntfy configuration (can be overridden via environment variables)
NTFY_URL = os.environ.get("NTFY_URL", "http://192.168.0.92:2586").rstrip("/")
NTFY_TOPIC = os.environ.get("NTFY_TOPIC", "codex").strip("/") or "codex"
NTFY_ENABLED = os.environ.get("NTFY_ENABLED", "1") not in {"0", "false", "False", "no", ""}


def _log(message: str) -> None:
    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        timestamp = datetime.now().isoformat(timespec="seconds")
        with LOG_PATH.open("a", encoding="utf-8") as fh:
            fh.write(f"[{timestamp}][pid:{os.getpid()}] {message}\n")
    except OSError:
        pass


def _stringify(value: object) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, (list, tuple)):
        return " \u2022 ".join(str(item) for item in value if item)
    return str(value)


def _truncate(text: str, limit: int) -> str:
    text = text.strip()
    if len(text) <= limit:
        return text
    return text[: limit - 1].rstrip() + "\u2026"


def _ensure_beep() -> Path | None:
    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
    except OSError:
        return None

    if BEEP_PATH.exists():
        return BEEP_PATH

    sample_rate = 44100
    duration = 0.25
    frequency = 880
    amplitude = 0.3
    frames = int(sample_rate * duration)

    try:
        with wave.open(str(BEEP_PATH), "w") as wav:
            wav.setnchannels(1)
            wav.setsampwidth(2)
            wav.setframerate(sample_rate)
            for i in range(frames):
                value = int(32767 * amplitude * math.sin(2 * math.pi * frequency * i / sample_rate))
                wav.writeframes(struct.pack("<h", value))
    except OSError as exc:
        _log(f"failed to generate beep: {exc}")
        return None

    return BEEP_PATH


def _ensure_custom_sound() -> Path | None:
    if not DOWNLOAD_SOUND.exists():
        _log(f"custom sound not found at {DOWNLOAD_SOUND}")
        return None

    try:
        CACHE_DIR.mkdir(parents=True, exist_ok=True)
        shutil.copy2(DOWNLOAD_SOUND, SOUND_PATH)
    except OSError as exc:
        _log(f"failed to copy custom sound: {exc}")
        return None
    return SOUND_PATH


def _select_player() -> str | None:
    for candidate in ("pw-play", "paplay", "aplay"):
        path = shutil.which(candidate)
        if path:
            return path
    return None


def _play_sound() -> None:
    player = _select_player()
    if not player:
        _log("no audio player available; skipping sound")
        return

    sound: Path | None
    if os.path.basename(player) == "pw-play":
        sound = _ensure_custom_sound() or _ensure_beep()
    else:
        # paplay/aplay handle wav reliably; fall back to generated beep.
        sound = _ensure_beep()

    if not sound or not sound.exists():
        _log("no sound file ready; skipping sound")
        return

    try:
        subprocess.Popen(
            [player, str(sound)],
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        _log(f"playing sound via {player} path={sound}")
    except OSError as exc:
        _log(f"failed to play sound: {exc}")


def _post_ntfy(title: str, body: str) -> None:
    if not NTFY_ENABLED:
        return
    url = f"{NTFY_URL}/{NTFY_TOPIC}"
    # Compose a concise message: prefer title; include body on a new line if present.
    message = title if not body else f"{title}\n{body}"
    data = message.encode("utf-8", errors="ignore")
    req = request.Request(url, data=data, method="POST")
    req.add_header("Content-Type", "text/plain; charset=utf-8")
    try:
        with request.urlopen(req, timeout=3) as resp:
            # 2xx indicates success; capture minimal info for the log
            _log(f"ntfy posted: {resp.status} {resp.reason} -> {url}")
    except urlerror.URLError as exc:
        _log(f"ntfy post failed: {exc}")
    except Exception as exc:  # pragma: no cover - defensive
        _log(f"ntfy unexpected error: {exc}")


def _send_notification(title: str, body: str) -> None:
    gdbus = shutil.which("gdbus")
    if not gdbus:
        _log("gdbus not found; cannot send notification")
        return

    args = [
        gdbus,
        "call",
        "--session",
        "--dest",
        "org.freedesktop.Notifications",
        "--object-path",
        "/org/freedesktop/Notifications",
        "--method",
        "org.freedesktop.Notifications.Notify",
        APP_NAME,
        "0",
        APP_ICON,
        title,
        body,
        json.dumps([]),
        "{}",
        str(EXPIRE_TIMEOUT_MS),
    ]

    try:
        raw = subprocess.check_output(args, text=True)
        _log(f"notification dispatched: {raw.strip()}")
    except subprocess.CalledProcessError as exc:
        _log(f"failed to send notification: {exc}")


def _handle_payload(raw: str) -> None:
    payload = json.loads(raw)
    if payload.get("type") != "agent-turn-complete":
        return

    assistant_msg = _stringify(
        payload.get("last-assistant-message") or payload.get("last_assistant_message")
    )
    inputs = payload.get("input_messages") or payload.get("input-messages")
    body = _stringify(inputs)

    title = assistant_msg or "Codex: Turn Complete"
    title = _truncate(title if title.startswith("Codex:") else f"Codex: {title}", 120)
    body = _truncate(body, 280)

    _play_sound()
    _send_notification(title, body)
    _post_ntfy(title, body)


def _usage() -> None:
    print("Usage: codex_notify.py <NOTIFICATION_JSON>", file=sys.stderr)


def main(argv: list[str]) -> int:
    if len(argv) != 2:
        _usage()
        return 1

    try:
        _handle_payload(argv[1])
    except json.JSONDecodeError:
        print("Invalid notification payload", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
