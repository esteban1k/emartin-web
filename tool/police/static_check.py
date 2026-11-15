#!/usr/bin/env python3
"""Police checks for emartin-web: UTF-8, title, and closed html on public pages."""

from __future__ import annotations

import argparse
import sys
from pathlib import Path


def finding(severity: str, text: str) -> str:
    return f"<!-- police:{severity} -->\n- **{severity}** · {text}\n"


def collect_pages(root: Path) -> list[Path]:
    required = [
        root / "index.html",
        root / "sobre-mi.html",
        root / "proyecto-qa.html",
    ]
    pages = list(required)
    for sub in ("cocina", "dev", "qa", "neuro"):
        legacy = root / sub / "index.html"
        if legacy.exists():
            pages.append(legacy)
    return pages


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--root", type=Path, default=Path("."))
    args = ap.parse_args()
    chunks: list[str] = []
    for page in collect_pages(args.root):
        rel = page.relative_to(args.root)
        if not page.exists():
            chunks.append(finding("blocker", f"falta `{rel}`."))
            continue
        try:
            text = page.read_text(encoding="utf-8")
        except UnicodeError:
            chunks.append(finding("blocker", f"`{rel}` no es UTF-8."))
            continue
        if not text.strip():
            chunks.append(finding("blocker", f"`{rel}` está vacío."))
            continue
        lower = text.lower()
        if "<title>" not in lower or "</title>" not in lower:
            chunks.append(finding("warning", f"`{rel}` no tiene `<title>`."))
        if "</html>" not in lower:
            chunks.append(finding("warning", f"`{rel}` no cierra `</html>`."))
        if "charset" not in lower:
            chunks.append(finding("nice", f"`{rel}` no declara charset."))
    cname = args.root / "CNAME"
    if not cname.exists():
        chunks.append(finding("blocker", "falta `CNAME` (dominio Pages)."))
    elif "emartin.com.ar" not in cname.read_text(encoding="utf-8"):
        chunks.append(finding("warning", "`CNAME` no menciona emartin.com.ar."))
    sys.stdout.write("".join(chunks))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())