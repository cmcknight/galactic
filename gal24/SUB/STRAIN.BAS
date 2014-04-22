
REM UWP Strainer v1.1
REM Public Domain 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com

REM Usage = strain gals\galaxy\sector\ X
REM    where X = A-P if straining one subsector
REM       or X = * if straining whole sector

DIM tabs(8)
DIM subsec$(16)
DIM world$(2)
DIM wo$(2)
DIM ws$(2)

SCREEN 0
c$ = COMMAND$
REM c$ = UCASE$("gals\var1\gythios\ *")

IF c$ = "" GOTO 10
c$ = RTRIM$(LCASE$(c$))
subc$ = UCASE$(RIGHT$(c$, 1))
c$ = LEFT$(c$, LEN(c$) - 2)
secdir$ = c$
mapdir$ = c$ + "map\"
straind$ = mapdir$ + "strained\"
c$ = RIGHT$(c$, LEN(c$) - 5)
l = LEN(c$)
a = INSTR(c$, "\")
IF a = 0 GOTO 10
sec$ = MID$(c$, a + 1, l - a - 1)
secfile$ = secdir$ + sec$ + ".dat"
OPEN "i", 1, secfile$
FOR a = 1 TO 2
  LINE INPUT #1, t$
NEXT a
FOR a = 1 TO 16
   LINE INPUT #1, t$
   l = LEN(t$)
   IF l > 45 THEN
      subsec$(a) = RTRIM$(MID$(t$, 30, 12))
   ELSE
      subsec$(a) = RTRIM$(RIGHT$(t$, l - 29))
   END IF
NEXT a
CLOSE 1
GOTO 20

10 CLS : COLOR 11
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 1000
GOTO 10000

20 GOSUB 5700: REM read configuration
FOR a = 1 TO 8
   READ tabs(a)
NEXT a
world$(1) = STRING$(65, 237)
world$(2) = STRING$(65, 237)
p1 = 1: p2 = 1
wo$(1) = "Test World    0101 C123456-7  N Ag Na In Ni Ri  R  890 Im 123 fxh"
wo$(2) = "Test NonWorld 1010 *1 This could be anything    A      Na     f h"

50 REM display
redraw = 0
CLS : COLOR 14
PRINT "UWP Strainer by jimv": PRINT
COLOR 10
PRINT "[Planet Name   Loc. UPP Code   B Notes           Z  PBG Al LRX *  ]"
PRINT "[-----------   ---- ---------  - --------------- -  --- -- --- -  ]"
PRINT "["; world$(1); "] World"
PRINT
PRINT "["; world$(2); "] Non-World"
COLOR 11
PRINT
FOR b = 1 TO 2
   PRINT "["; wo$(b); "] Original"
   ws$(b) = ""
   FOR a = 1 TO 65
      v1 = ASC(MID$(world$(b), a, 1))
      v2 = ASC(MID$(wo$(b), a, 1))
      IF v1 = 237 THEN
         t$ = CHR$(v2)
      ELSE
         t$ = CHR$(v1)
      END IF
      ws$(b) = ws$(b) + t$
   NEXT a
   PRINT "["; ws$(b); "] Strained"
   PRINT
NEXT b
PRINT
COLOR 13
PRINT " F1 = Restore Null (let original character pass through)"
PRINT " F2 = Help"
PRINT "Ins = Strain the ";
IF subc$ = "*" THEN
   PRINT "Sector";
ELSE
   PRINT "Subsector";
END IF
PRINT " (into "; LEFT$(straind$, LEN(straind$) - 1); ")"
PRINT "Esc = Exit w/o Straining"
PRINT

LOCATE 4 + p2 * 2, p1 + 1: COLOR 14
PRINT "^"
COLOR 11

100 REM get input
GOSUB 1000
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND k1 >= 32 AND k1 <= 126 GOTO 110: REM all chars
IF k2 = 1 AND k1 = 72 OR k1 = 80 GOTO 108: REM up/down
IF k2 = 1 AND k1 = 75 OR k1 = 77 THEN GOTO 150: REM left/right
IF k2 = 0 AND k1 = 8 THEN GOTO 150: REM backspace
IF k2 = 0 AND k1 = 9 THEN GOTO 105: REM tab
IF k2 = 1 AND k1 = 15 THEN GOTO 105: REM shift-tab
IF k2 = 1 AND k1 = 59 GOTO 110: REM F1 (restore null)
IF k2 = 1 AND k1 = 60 GOTO 200: REM F2 (help)
IF k2 = 1 AND k1 = 82 GOTO 6000: REM Ins
GOTO 100

105 REM tabs
LOCATE 4 + p2 * 2, p1 + 1: PRINT " "
IF k1 = 9 THEN
 FOR a = 7 TO 2 STEP -1
  IF p1 >= tabs(a) AND p1 < tabs(a + 1) THEN p1 = tabs(a + 1)
 NEXT a
END IF
IF k1 = 15 THEN
 FOR a = 2 TO 7
  IF p1 > tabs(a - 1) AND p1 <= tabs(a) THEN p1 = tabs(a - 1)
 NEXT a
END IF
COLOR 14: LOCATE 4 + p2 * 2, p1 + 1: PRINT "^"
GOTO 100

108 REM up/down
LOCATE 4 + p2 * 2, p1 + 1: PRINT " "
tmp = p2
IF tmp = 1 THEN p2 = 2
IF tmp = 2 THEN p2 = 1
COLOR 14: LOCATE 4 + p2 * 2, p1 + 1: PRINT "^"
GOTO 100

110 REM alpha-numeric & some
IF k2 = 1 AND k1 = 59 THEN k1 = 237
IF p1 = 1 THEN
   a1$ = ""
   a3$ = RIGHT$(world$(p2), 64)
END IF
IF p1 = 65 THEN
   a1$ = LEFT$(world$(p2), 64)
   a3$ = ""
END IF
IF p1 <> 1 AND p1 <> 65 THEN
   a1$ = LEFT$(world$(p2), p1 - 1)
   a3$ = RIGHT$(world$(p2), 65 - p1)
END IF
IF p1 = 1 AND k1 = 32 THEN k1 = 46: REM space -> period
a2$ = CHR$(k1)
world$(p2) = a1$ + a2$ + a3$
SOUND 10000, .1
redraw = 1: k1 = 77

150 REM left & right
LOCATE 4 + p2 * 2, p1 + 1: PRINT " "
IF k1 = 75 THEN p1 = p1 - 1
IF k1 = 8 THEN p1 = p1 - 1
IF k1 = 77 THEN p1 = p1 + 1
IF p1 = 0 THEN p1 = 65
IF p1 = 66 THEN p1 = 1
COLOR 14: LOCATE 4 + p2 * 2, p1 + 1: PRINT "^"
IF redraw = 1 GOTO 50
GOTO 100

200 REM help
GOSUB 5500
SHELL reader$ + " help\strain.txt"
SCREEN 12
SCREEN 0
GOTO 50

1000 REM read keyboard
k1 = 0: k2 = 0
1002 k$ = INKEY$
IF k$ = "" GOTO 1002
k1 = ASC(k$)
IF k1 <> 0 GOTO 1004
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
1004 RETURN

5500 REM egacolor gold on blue
CLS
SHELL "call xtra\egacolor 00 10"
SHELL "call xtra\egacolor 07 46"
RETURN

5700 REM read in settings
OPEN "i", 1, "gal.cfg"
INPUT #1, t$: l = LEN(t$)
editor$ = RIGHT$(t$, l - 7)
INPUT #1, t$: l = LEN(t$)
reader$ = RIGHT$(t$, l - 7)
CLOSE 1
RETURN

6000 REM write new subsector file
CLS : COLOR 11
newdir$ = LEFT$(straind$, LEN(straind$) - 1)
PRINT "Creating "; newdir$
SHELL "mkdir " + newdir$
PRINT
IF subc$ = "*" THEN
   FOR a = 1 TO 16
      GOSUB 6100
   NEXT a
ELSE
   a = ASC(subc$) - 64
   GOSUB 6100
END IF
PRINT
PRINT "Done  -  Hit any key to exit"
GOSUB 1000
GOTO 10000

6100 REM
infile$ = mapdir$ + subsec$(a)
outfile$ = straind$ + subsec$(a)
PRINT "Writing "; outfile$
OPEN "i", 1, infile$
OPEN "o", 2, outfile$
REM get past jump routes and other muck
break$ = "#----------   ---- ---------  - --------"
break$ = break$ + "------- -  --- -- --- -"
t$ = ""
DO UNTIL t$ = break$ OR EOF(1)
   LINE INPUT #1, t$
   PRINT #2, t$
LOOP
REM read worlds
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LEN(t$) > 20 THEN
      IF MID$(t$, 20) <> "*" THEN
         REM world
         c = 1
      ELSE
         REM non-world
         c = 2
      END IF
      t2$ = ""
      FOR b = 1 TO LEN(t$)
         v1 = ASC(MID$(world$(c), b, 1))
         v2 = ASC(MID$(t$, b, 1))
         IF v1 = 237 THEN
            t3$ = CHR$(v2)
         ELSE
            t3$ = CHR$(v1)
         END IF
         t2$ = t2$ + t3$
      NEXT b
      t$ = t2$
   END IF
   PRINT #2, t$
LOOP
CLOSE 1
CLOSE 2
RETURN

REM tabs
DATA 1,1,15,20,33,52,65,65

10000 REM end
COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email: jimv@empirenet.com"
PRINT "            jimvassila@aol.com"
END

