#!/usr/bin/env python3
"""Build the novyra wiki.

Reads markdown sources from docs/wiki-src/ and the page layout from
docs/wiki-layout.json, then renders the wiki HTML pages in docs/wiki/.

Usage:
    python3 scripts/build-wiki.py            # build all pages
    python3 scripts/build-wiki.py --check    # verify pages are up to date (CI)

Branding rules:
    - "novyra" is always spelt with a lowercase "n".
    - The main accent colour is #238FC9 (see docs/wiki.css).
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from html import escape
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
SRC_DIR = ROOT / "docs" / "wiki-src"
LAYOUT_FILE = ROOT / "docs" / "wiki-layout.json"
OUT_DIR = ROOT / "docs" / "wiki"

SITE_URL = "https://CStaks.github.io/novyra/"
REPO_URL = "https://github.com/CStaks/novyra"
BRAND = "novyra"  # always lowercase


# ---------------------------------------------------------------------------
# Markdown -> HTML (small, purpose-built subset)
# ---------------------------------------------------------------------------

def md_inline(text: str) -> str:
    """Render inline markdown: code, bold, italics and links."""
    text = escape(text)
    text = re.sub(r"`([^`]+)`", r"<code>\1</code>", text)
    text = re.sub(r"\*\*([^*]+)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"(?<!\*)\*([^*]+)\*(?!\*)", r"<em>\1</em>", text)
    text = re.sub(
        r"\[([^\]]+)\]\(([^)]+)\)",
        lambda m: f'<a href="{m.group(2)}">{m.group(1)}</a>',
        text,
    )
    return text


def slugify(text: str) -> str:
    text = re.sub(r"[^a-z0-9\s-]", "", text.lower())
    return re.sub(r"[\s]+", "-", text.strip())


def md_to_html(md: str) -> str:
    lines = md.splitlines()
    out: list[str] = []
    i = 0
    while i < len(lines):
        line = lines[i]

        if line.startswith("```"):
            lang = line[3:].strip()
            code: list[str] = []
            i += 1
            while i < len(lines) and not lines[i].startswith("```"):
                code.append(lines[i])
                i += 1
            i += 1  # closing fence
            cls = f' class="language-{lang}"' if lang else ""
            out.append(f"<pre><code{cls}>{escape(chr(10).join(code))}</code></pre>")
            continue

        if line.startswith("|") and i + 1 < len(lines) and re.match(r"^\|[\s:|-]+\|$", lines[i + 1]):
            header = [c.strip() for c in line.strip("|").split("|")]
            i += 2
            rows: list[list[str]] = []
            while i < len(lines) and lines[i].startswith("|"):
                rows.append([c.strip() for c in lines[i].strip("|").split("|")])
                i += 1
            out.append("<table>")
            out.append("<thead><tr>" + "".join(f"<th>{md_inline(c)}</th>" for c in header) + "</tr></thead>")
            out.append("<tbody>")
            for row in rows:
                out.append("<tr>" + "".join(f"<td>{md_inline(c)}</td>" for c in row) + "</tr>")
            out.append("</tbody></table>")
            continue

        if line.startswith("- "):
            out.append("<ul>")
            while i < len(lines) and lines[i].startswith("- "):
                out.append(f"<li>{md_inline(lines[i][2:])}</li>")
                i += 1
            out.append("</ul>")
            continue

        if re.match(r"^\d+\.\s", line):
            out.append("<ol>")
            while i < len(lines) and re.match(r"^\d+\.\s", lines[i]):
                content = re.sub(r"^\d+\.\s", "", lines[i])
                out.append(f"<li>{md_inline(content)}</li>")
                i += 1
            out.append("</ol>")
            continue

        if line.startswith("### "):
            out.append(f'<h3 id="{slugify(line[4:])}">{md_inline(line[4:])}</h3>')
            i += 1
            continue
        if line.startswith("## "):
            out.append(f'<h2 id="{slugify(line[3:])}">{md_inline(line[3:])}</h2>')
            i += 1
            continue
        if line.startswith("# "):
            out.append(f'<h1 id="{slugify(line[2:])}">{md_inline(line[2:])}</h1>')
            i += 1
            continue

        if line.strip():
            out.append(f"<p>{md_inline(line)}</p>")
        i += 1

    return "\n".join(out)


# ---------------------------------------------------------------------------
# Page templates
# ---------------------------------------------------------------------------

THEME_SNIPPET = """<script>
  const theme = localStorage.getItem('novyra-theme');
  if (theme === 'light' || (!theme && matchMedia('(prefers-color-scheme: light)').matches)) document.documentElement.classList.add('light');
</script>"""

PAGE_SCRIPT = """<script>
  const root = document.documentElement;
  const toggle = document.querySelector('.wiki-theme-toggle');
  function updateTheme() {
    const light = root.classList.contains('light');
    toggle.textContent = light ? '☾' : '☼';
    toggle.setAttribute('aria-label', light ? 'Switch to dark theme' : 'Switch to light theme');
  }
  toggle.addEventListener('click', () => {
    root.classList.toggle('light');
    localStorage.setItem('novyra-theme', root.classList.contains('light') ? 'light' : 'dark');
    updateTheme();
  });
  updateTheme();
</script>"""


def render_nav(layout: dict[str, list[str]], active: str | None) -> str:
    parts = ["<h2>Getting started</h2>", "<ul>"]
    for pages in layout.values():
        for page in pages:
            name, slug, _, _ = PAGES[page]
            href = f"{slug}.html"
            cls = ' class="active"' if page == active else ""
            parts.append(f'<li><a href="{href}"{cls}>{escape(name)}</a></li>')
    parts.append("</ul>")
    return "\n".join(parts)


def render_page(title: str, description: str, body: str, nav: str) -> str:
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>{escape(title)} · {BRAND} Wiki</title>
<meta name="description" content="{escape(description)}">
<link rel="stylesheet" href="../wiki.css">
<link rel="icon" href="../primary-dark-logo.ico" media="(prefers-color-scheme: dark)">
<link rel="icon" href="../primary-light-logo.ico" media="(prefers-color-scheme: light)">
{THEME_SNIPPET}
</head>
<body>
<header class="wiki-topbar">
  <div class="wiki-topbar-inner">
    <a class="wiki-brand" href="index.html">{BRAND}<span class="wiki-brand-dot"> · Wiki</span></a>
    <div class="wiki-actions">
      <a class="wiki-back" href="{SITE_URL}">← Back to {BRAND}</a>
      <button class="wiki-theme-toggle" type="button" aria-label="Switch to light theme">☼</button>
    </div>
  </div>
</header>
<div class="wiki-layout">
  <nav class="wiki-nav" aria-label="Wiki pages">
{nav}
  </nav>
  <main class="wiki-content">
{body}
  </main>
</div>
<footer class="wiki-footer">
  <div class="wiki-footer-inner">
    <span>{BRAND} OS documentation.</span>
    <span><a href="{SITE_URL}">{BRAND} OS</a></span>
  </div>
</footer>
{PAGE_SCRIPT}
</body>
</html>
"""


def render_index(layout: dict[str, list[str]]) -> str:
    nav = render_nav(layout, None)
    links = []
    for pages in layout.values():
        for page in pages:
            name, slug, _, _ = PAGES[page]
            links.append(f'  <li><a href="{slug}.html">{escape(name)}</a></li>')
    body = (
        f"<p>Installation notes and practical guides for {BRAND} OS.</p>\n"
        "<h2>Getting started</h2>\n<ul>\n" + "\n".join(links) + "\n</ul>"
    )
    return f"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>Wiki home · {BRAND} Wiki</title>
<link rel="stylesheet" href="../wiki.css">
<link rel="icon" href="../primary-dark-logo.ico" media="(prefers-color-scheme: dark)">
<link rel="icon" href="../primary-light-logo.ico" media="(prefers-color-scheme: light)">
{THEME_SNIPPET}
</head>
<body>
<header class="wiki-topbar">
  <div class="wiki-topbar-inner">
    <a class="wiki-brand" href="index.html">{BRAND}<span class="wiki-brand-dot"> · Wiki</span></a>
    <div class="wiki-actions">
      <a class="wiki-back" href="{SITE_URL}">← Back to {BRAND}</a>
      <button class="wiki-theme-toggle" type="button" aria-label="Switch to light theme">☼</button>
    </div>
  </div>
</header>
<div class="wiki-layout">
  <nav class="wiki-nav" aria-label="Wiki pages">
{nav}
  </nav>
  <main class="wiki-content">
{body}
  </main>
</div>
<footer class="wiki-footer">
  <div class="wiki-footer-inner">
    <span>{BRAND} OS documentation.</span>
    <span><a href="{SITE_URL}">{BRAND} OS</a></span>
  </div>
</footer>
{PAGE_SCRIPT}
</body>
</html>
"""


# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

PAGES: dict[str, tuple[str, str, str, str]] = {}


def load_pages() -> None:
    """Load markdown sources; PAGES maps filename -> (name, slug, description, body_md)."""
    for md_file in sorted(SRC_DIR.glob("*.md")):
        text = md_file.read_text(encoding="utf-8")
        meta: dict[str, str] = {}
        if text.startswith("---"):
            end = text.index("---", 3)
            for line in text[3:end].strip().splitlines():
                if ":" in line:
                    key, value = line.split(":", 1)
                    meta[key.strip()] = value.strip()
            text = text[end + 3 :].lstrip("\n")
        name = meta.get("name", md_file.stem.replace("-", " ").title())
        description = meta.get("description", "")
        PAGES[md_file.name] = (name, md_file.stem, description, text)


def build() -> dict[str, str]:
    layout = json.loads(LAYOUT_FILE.read_text(encoding="utf-8"))
    output: dict[str, str] = {str(OUT_DIR / "index.html"): render_index(layout)}

    for active, pages in layout.items():
        for page in pages:
            if page not in PAGES:
                sys.exit(f"error: layout references unknown page '{page}'")
            name, slug, description, text = PAGES[page]
            body = md_to_html(text)
            nav = render_nav(layout, page)
            output[str(OUT_DIR / f"{slug}.html")] = render_page(name, description, body, nav)
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description="Build the novyra wiki HTML pages.")
    parser.add_argument("--check", action="store_true", help="verify generated pages are up to date")
    args = parser.parse_args()

    load_pages()
    output = build()

    if args.check:
        stale = []
        for path_str, content in output.items():
            path = Path(path_str)
            if not path.exists() or path.read_text(encoding="utf-8") != content:
                stale.append(str(path.relative_to(ROOT)))
        if stale:
            print("Wiki pages out of date. Run: python3 scripts/build-wiki.py")
            for path in stale:
                print(f"  {path}")
            sys.exit(1)
        print("Wiki pages are up to date.")
        return

    OUT_DIR.mkdir(parents=True, exist_ok=True)
    for path_str, content in output.items():
        Path(path_str).write_text(content, encoding="utf-8")
        print(f"wrote {Path(path_str).relative_to(ROOT)}")


if __name__ == "__main__":
    main()
