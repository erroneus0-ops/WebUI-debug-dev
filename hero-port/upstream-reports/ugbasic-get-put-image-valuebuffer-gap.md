Title: Classic GET(x,y)-(x2,y2),name syntax doesn't set the image's valueBuffer, so PUT always reports "uninitialized"

## Summary

The classic Dragon/CoCo-style `GET(x1,y1)-(x2,y2),name` syntax is
implemented (confirmed via the grammar in ugbc.y -- it maps to the
same internal `get_image()` function as the modern `GET IMAGE`
syntax), and correctly computes and stores the image's width/height
via `get_image_overwrite_size()`. However, it never sets the image
variable's `valueBuffer` field. Every `PUT` variant unconditionally
calls `build_resource_for_sequence()`, which checks exactly that field
and refuses with `E254 - PUT IMAGE with uninitialized image variable`
if it's unset -- so a `GET` followed by a `PUT` of the very same
image, with no `LOAD IMAGE` or other resource step in between, always
fails on the `PUT`, even though the `GET` itself completed with no
error at all.

## Environment

- ugBASIC v1.18.1 (built from source)
- Target: coco (Motorola 6809)
- Invocation: `ugbc.coco -W source.bas source.asm`

## Minimal reproduction

```basic
PMODE 4, 1
CLS
DIM q AS IMAGE
BOX 10,10 TO 25,33
GET(10,10)-(25,33),q
PUT(80,80)-(95,103),q
DO
LOOP
```

`GET` compiles with no error. `PUT` fails:

```
*** ERROR: E254 - PUT IMAGE with uninitialized image variable (q) at 6 column 21 (93)
```

Traced through the source: `get_image()` (coco/get_image.c) calls
`get_image_overwrite_size()` (targets/common/_infrastructure.c) when
both corner coordinates are given, which correctly stores width/height
into the image's variable header via a sequence of
`cpu_move_16bit`/`cpu_addressof_16bit`/`cpu_math_add_16bit_const`/
`cpu_move_8bit_indirect` calls -- but nothing in that path touches
`valueBuffer`. Meanwhile every `put_image()` code path (coco/
put_image.c) unconditionally calls `build_resource_for_sequence()`,
which is the function that actually raises this error, checking:

```c
if ( ! image->valueBuffer && image->type != VT_ADDRESS ) {
    CRITICAL_PUT_IMAGE_UNINITIALIZED( _image );
}
```

## What I tried

- Declaring the image with `DIM q AS IMAGE` before `GET`/`PUT`: fails
  as above.
- Omitting the `DIM` and letting `GET` auto-declare it: fails earlier,
  with `E097 - GET IMAGE unsupported for given datatype (q, SWORD)`,
  since without an explicit declaration the variable defaults to a
  plain integer type instead of `VT_IMAGE`.
- Declaring as a plain sized array (`DIM q(10)`, matching the pattern
  used throughout the original 1980s BASIC program I'm porting, which
  predates the modern `IMAGE` datatype): fails at `PUT` with a related
  but distinct error, `E088 - PUT IMAGE unsupported for given datatype
  (q, ARRAY)`.
- Declaring with explicit dimensions (`DIM q(16,24) AS IMAGE`): fails
  to parse at all, `E003 - Datatype not supported for keyword
  (array(1a), IMAGE)`.

None of the variations I tried get past the `PUT` step for a pure
GET-then-PUT round trip with no `LOAD IMAGE`/resource step involved.

## Impact

This appears to make the classic `GET`/`PUT` syntax pair unusable for
its most basic use case -- capturing a piece of the current screen at
runtime and redrawing it elsewhere later -- which is exactly the
scenario the classic syntax exists to support (it's how essentially
all CoCo/Dragon BASIC games built sprite systems in the 1980s, and
`GET`/`PUT` are documented as working "with the same syntax" for
runtime screen capture in the user manual's Images page). Anyone
porting an existing BASIC program that relies on this pattern (mine
included) will hit this on the very first `GET`/`PUT` pair.

## Workaround

None found that stays within the `GET`/`PUT`/`IMAGE` system. Falling
back to raw memory copies via inline assembly instead (reading/writing
the known PMODE4/SG12 framebuffer layout directly, using
`BITMAPADDRESS` as the base) for now.

Found this while trying to port a small sprite system during a
from-scratch port of an existing CoCo BASIC game -- happy to test
further, provide the full generated .asm, or dig into
`get_image_overwrite_size`/`build_resource_for_sequence` further if
useful.
