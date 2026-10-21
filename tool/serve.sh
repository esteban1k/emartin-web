#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PORT="${PORT:-8765}"
echo "Serving $ROOT on http://127.0.0.1:$PORT"
exec python3 -m http.server "$PORT" --bind 127.0.0.1
