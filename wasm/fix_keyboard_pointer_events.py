#!/usr/bin/env python3
"""
fix_keyboard_pointer_events.py

Problem this solves:
  Anything drawn "on top" of the interactive key-* cells in
  coco3_keyboard.svg -- the character glyphs, the shader overlay image --
  intercepts clicks/taps before they reach the actual key cells
  underneath, because SVG's default pointer-events behavior lets a
  painted shape absorb pointer events even if nothing is wired to it.

What this script does:
  Finds the LAST key-* cell in document order, and adds
  pointer-events:none to every style="..." attribute found AFTER that
  point (the glyph/label layer and the shader image) -- so clicks pass
  straight through the decoration to the key cells underneath. Anything
  BEFORE that point (the key-* cells themselves) is left untouched.

Why this needs to be a script you re-run, not a one-time fix:
  Inkscape's own save process can rewrite or strip style attributes it
  didn't add itself. Every time you edit and re-save the SVG in
  Inkscape, run this again to make sure the pointer-events fix is still
  in place -- it's idempotent (safe to run repeatedly; already-fixed
  attributes are left alone, not duplicated).

IMPORTANT ASSUMPTION, worth knowing before trusting this blindly:
  This assumes the document is structured as "all key-* cells first,
  then all decorative elements after." If you ever restructure things
  so decorative elements appear interleaved with or before some key-*
  cells, this script's simple "everything after the last key" rule
  will not correctly target every decorative element -- check the
  dry-run output carefully if you've changed the document structure.

Usage:
  python3 fix_keyboard_pointer_events.py coco3_keyboard.svg
      Applies the fix directly to the file.

  python3 fix_keyboard_pointer_events.py coco3_keyboard.svg --dry-run
      Shows what would change without touching the file.
"""
import sys
import re


def fix_pointer_events(svg_path, dry_run=False):
    with open(svg_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find the last key-* cell id in document order. Everything after this
    # point is treated as decorative/"on top" and gets pointer-events:none.
    last_key_match = None
    for m in re.finditer(r'id="key-[^"]+"', content):
        last_key_match = m

    if last_key_match is None:
        print("No key-* elements found in this file -- wrong file, or "
              "naming convention changed? Nothing done.")
        return False

    # IMPORTANT: use the end of the FULL TAG containing this id, not just
    # the end of the id="key-X" string itself. A real bug this caught: if
    # id appears BEFORE style within that key's own tag (rather than
    # after, which was the assumption originally), using the id string's
    # own end position lands INSIDE that tag -- meaning the key's own
    # style attribute would get caught in the "everything after" sweep
    # and wrongly given pointer-events:none, making that one key
    # unclickable. Search forward from the id match to that tag's actual
    # closing '>' instead, which is correct regardless of attribute order.
    tag_close = content.find('>', last_key_match.end())
    if tag_close == -1:
        print("Could not find the closing '>' for the last key's tag -- "
              "malformed SVG? Nothing done.")
        return False
    last_key_pos = tag_close + 1
    head = content[:last_key_pos]
    tail = content[last_key_pos:]

    changed = []

    def add_pointer_events_none(m):
        style = m.group(1)
        if 'pointer-events' in style:
            return m.group(0)  # already set -- leave alone, idempotent
        changed.append(style[:60])
        return 'style="' + style + ';pointer-events:none"'

    new_tail, _ = re.subn(r'style="([^"]*)"', add_pointer_events_none, tail)
    count = len(changed)  # re.subn's own count includes skipped (already-fixed)
                          # matches too -- use the actual changed-items list instead

    if count == 0:
        print("Nothing to do -- every style attribute after the last "
              "key-* cell already has pointer-events:none set.")
        return True

    if dry_run:
        print(f"[dry run] Would add pointer-events:none to {count} "
              f"style attribute(s):")
        for c in changed[:10]:
            print(f"  - {c}...")
        if len(changed) > 10:
            print(f"  ... and {len(changed) - 10} more")
        print("Run again without --dry-run to actually apply this.")
        return True

    with open(svg_path, 'w', encoding='utf-8') as f:
        f.write(head + new_tail)

    print(f"Done -- added pointer-events:none to {count} style attribute(s).")
    return True


if __name__ == '__main__':
    args = sys.argv[1:]
    dry_run = '--dry-run' in args
    args = [a for a in args if a != '--dry-run']

    if len(args) != 1:
        print(__doc__)
        sys.exit(1)

    fix_pointer_events(args[0], dry_run=dry_run)
