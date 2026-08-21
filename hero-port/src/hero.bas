' ============================================================================
' HERO port -- title screen (first real piece of the actual port, not a
' test file)
'
' Ported from HERO-SRC.BAS lines 2810-2900 (see hero-port/HERO-SOURCE-
' ANALYSIS.md, section "title_page"). This is plain SCREEN 0 text mode --
' no PMODE4, no SG12, none of this project's graphics-hack machinery is
' needed for this particular screen at all.
'
' VERIFIED AGAINST THE REAL GAME: booted the actual, original HERO-11.DSK
' in XRoar earlier this project and screenshotted its real title screen
' for direct comparison. Text content, layout, and the two-box visual
' structure all match closely.
'
' KNOWN GAP, not yet solved: the original highlights the first letter of
' each line (H/E/R/O) in inverse video -- real hardware achieves this by
' writing character byte values from the second half of the CoCo's
' alphanumeric character set (POKEing value-64 rather than the normal
' ASCII value). ugBASIC's own INVERSE ON/OFF statement is explicitly
' unsupported for this target ("CRITICAL_NOT_SUPPORTED"), and INK INVERSE
' doesn't parse as a valid argument either -- confirmed via direct
' testing, not assumed. Likely fix: replicate the original's own
' technique directly, writing raw character bytes to text-mode screen
' memory via our own inline-assembly approach (same STRPTR-based pattern
' as sgprint/sgfill), rather than relying on a ugBASIC text-attribute
' feature that isn't there. Left as a follow-up rather than blocking this
' push.
' ============================================================================

SCREEN 0
CLS

SET TAB 12
PRINT "H OVERJET"
SET TAB 12
PRINT "E MERGENCY"
SET TAB 12
PRINT "R ESCUE"
SET TAB 12
PRINT "O PERATION"
PRINT

sepline$ = STRING(CHR(140), 32)
PRINT "  VERSION 1.1   SEPTEMBER 2024"
PRINT sepline$

DO
LOOP
