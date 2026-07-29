#!/usr/bin/env python3
"""
fix_keyboard_label_naming.py

Applies the agreed label naming scheme to coco3_keyboard.svg's
inkscape:label attributes:

  - Letters:        "character X" -> "X char"   (A through Z)
  - Numbers:        left as-is ("number zero" etc. -- already clear)
  - Bare symbols:   " char" appended (asterisk, semicolon, colon,
                    close/open parenthesis, apostrophe, ampersand)
  - Already-marked: left as-is (anything already ending in "sign" or
                    "mark", e.g. "at sign", "question mark")
  - "slash character" -> "slash char" (standardizing on "char", not
                    "character", throughout)

Also fixes two known typos if present:
  - "exclaimation mark" -> "exclamation mark"
  - "open parentheis"   -> "open parenthesis"

Idempotent -- safe to run repeatedly. Like fix_keyboard_pointer_events.py,
meant to be re-run after every Inkscape edit/re-save, since Inkscape's
own save process can revert manually-typed labels if you re-touch the
same object in its XML/Objects editor.

Usage:
  python3 fix_keyboard_label_naming.py coco3_keyboard.svg
  python3 fix_keyboard_label_naming.py coco3_keyboard.svg --dry-run
"""
import sys
import re

BARE_SYMBOLS = [
    'asterisk', 'semicolon', 'colon', 'close parenthesis',
    'open parenthesis', 'apostrophe', 'ampersand',
]


def fix_label_naming(svg_path, dry_run=False):
    with open(svg_path, 'r', encoding='utf-8') as f:
        content = f.read()

    original = content
    changes = []

    def note(desc):
        changes.append(desc)

    # Typos
    if 'exclaimation mark' in content:
        content = content.replace('exclaimation mark', 'exclamation mark')
        note("typo: exclaimation mark -> exclamation mark")
    if 'open parentheis' in content:
        content = content.replace('open parentheis', 'open parenthesis')
        note("typo: open parentheis -> open parenthesis")

    # Letters: "character X" -> "X char"
    def fix_letter(m):
        note(f"character {m.group(1)} -> {m.group(1)} char")
        return f'{m.group(1)} char'
    content = re.sub(r'\bcharacter ([A-Z])\b', fix_letter, content)

    # Bare symbols -> append " char"
    for sym in BARE_SYMBOLS:
        pattern = r'inkscape:label="' + re.escape(sym) + r'"'
        if re.search(pattern, content):
            content = re.sub(pattern, f'inkscape:label="{sym} char"', content)
            note(f'"{sym}" -> "{sym} char"')

    # slash character -> slash char
    if 'inkscape:label="slash character"' in content:
        content = content.replace(
            'inkscape:label="slash character"',
            'inkscape:label="slash char"'
        )
        note('"slash character" -> "slash char"')

    if content == original:
        print("Nothing to do -- naming scheme already applied.")
        return True

    if dry_run:
        print(f"[dry run] Would make {len(changes)} change(s):")
        for c in changes:
            print(f"  - {c}")
        print("Run again without --dry-run to actually apply this.")
        return True

    with open(svg_path, 'w', encoding='utf-8') as f:
        f.write(content)

    print(f"Done -- made {len(changes)} change(s).")
    return True


if __name__ == '__main__':
    args = sys.argv[1:]
    dry_run = '--dry-run' in args
    args = [a for a in args if a != '--dry-run']

    if len(args) != 1:
        print(__doc__)
        sys.exit(1)

    fix_label_naming(args[0], dry_run=dry_run)
