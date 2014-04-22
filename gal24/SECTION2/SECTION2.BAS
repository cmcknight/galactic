REM this is my own version of the section program

c$ = LCASE$(COMMAND$)

OPEN "o", 3, "align"
OPEN "o", 4, "bases"

FOR a = 1 TO 16
   OPEN "i", 1, c$ + ".sec"
   f$ = "sec_" + CHR$(64 + a)
   OPEN "o", 2, f$ + ".dat"
   PRINT "Writing "; f$; ".dat"
   PRINT #2, "@SUB-SECTOR: "; f$; "   SECTOR: "; c$
   PRINT #2, "#"
   PRINT #2, "# Trade routes within the subsector"
   PRINT #2, "#"
   PRINT #2, "#--------1---------2---------3---------4";
   PRINT #2, "---------5---------6---"
   PRINT #2, "#PlanetName   Loc. UPP Code   B   Notes ";
   PRINT #2, "        Z  PBG Al LRX *"
   PRINT #2, "#----------   ---- ---------  - --------";
   PRINT #2, "------- -  --- -- --- -"
   tr = 0
   DO UNTIL EOF(1)
      LINE INPUT #1, t$
      IF LEN(t$) > 79 THEN tr = 1
      IF tr = 0 GOTO 100
      IF LEN(t$) < 50 GOTO 100
      REM at this point we know that t$ is a starsystem
      t$ = LEFT$(t$, 57)
      p$ = MID$(t$, 15, 4)
      p1 = VAL(LEFT$(p$, 2))
      p2 = VAL(RIGHT$(p$, 2))
      h = INT((p1 - 1) / 8) + 1
      v = INT((p2 - 1) / 10) + 1
      f = h + ((v - 1) * 4)
      IF a = f THEN PRINT #2, t$
      al$ = RIGHT$(t$, 2)
      IF a = f THEN PRINT #3, al$
      ba$ = MID$(t$, 31, 1)
      IF a = f AND ba$ <> " " THEN PRINT #4, ba$
100 LOOP
CLOSE 1
CLOSE 2
NEXT a
CLOSE 3
CLOSE 4

SHELL "sort < align > align.srt"
SHELL "sort < bases > bases.srt"
SHELL "erase align"
SHELL "erase bases"
ff$(1) = "align"
ff$(2) = "bases"
FOR a = 1 TO 2
 OPEN "i", 1, ff$(a) + ".srt"
 OPEN "o", 2, ff$(a)
 t0$ = ""
 DO UNTIL EOF(1)
  LINE INPUT #1, t$
  IF t$ <> t0$ THEN
   PRINT #2, t$
   t0$ = t$
  END IF
 LOOP
 CLOSE 1
 CLOSE 2
NEXT a
SHELL "erase align.srt"
SHELL "erase bases.srt"

END

