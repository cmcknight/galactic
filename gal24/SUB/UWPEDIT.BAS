
REM Universal World Profile Editor v1.4
REM Public Domain 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com

REM Usage = uwpedit <subsector file> <hex#>

DIM excode$(2, 34)
DIM extech(34)
DIM exetc$(34)
DIM tccode$(15)
DIM tc(15)
DIM fixed$(21)
DIM fixloc(21)
DIM basalg$(2, 50, 2)
DIM basalgn(2)
DIM algncol(50)
DIM z$(12)
DIM tabs(8)
DIM uwpstat$(15): REM stat names
DIM uwpnum(15): REM number of definitions per stat
DIM uwppos(15, 3): REM positions (main & mod) & color of stats
DIM uwpdef$(15, 40): REM value definitions
DIM uwpval(15, 40, 2): REM low & high values for each def

DEF fnnum (f11$)
   IF f11$ = LTRIM$(STR$(VAL(f11$))) THEN f12 = VAL(f11$)
   IF f11$ <> LTRIM$(STR$(VAL(f11$))) THEN
      f12 = ASC(f11$) - 55
   END IF
   fnnum = f12
END DEF
DEF fnlet$ (f13)
   IF f13 <= 9 THEN f14$ = LTRIM$(STR$(f13))
   IF f13 >= 10 THEN f14$ = CHR$(f13 + 55)
   fnlet$ = f14$
END DEF

DEF FNletter$ (f12)
   IF f12 <= 9 THEN f13$ = LTRIM$(STR$(f12))
   IF f12 >= 10 THEN f13$ = CHR$(f12 + 55)
   IF f12 >= 100 THEN f13$ = CHR$(f12 - 100)
   IF f12 >= 1000 THEN
      f13a = INT(f12 / 256)
      f13b = f12 - f13a
      f13$ = CHR$(f13a) + CHR$(f13b)
   END IF
   FNletter$ = f13$
END DEF

DEF FNnumber (f13$)
   f13$ = RTRIM$(LTRIM$(f13$))
   IF LEN(f13$) = 1 THEN
      SELECT CASE ASC(f13$)
         CASE 48 TO 57
            f12 = VAL(f13$)
         CASE 65 TO 90
            f12 = ASC(f13$) - 55
         CASE ELSE
            f12 = ASC(f13$) + 100
      END SELECT
   END IF
   IF LEN(f13$) = 2 THEN
      f13a$ = LEFT$(f13$, 1)
      f13b$ = RIGHT$(f13$, 1)
      f12 = (ASC(f13a$) * 256) + ASC(f13b$)
   END IF
   IF LEN(f13$) <> 1 AND LEN(f13$) <> 2 THEN
      f12 = 0
   END IF
   FNnumber = f12
END DEF

DEF FNuwp$ (f2)
f3len = 1
IF uwpval(f2, 1, 1) > 1000 THEN f3len = 2
f3a$ = MID$(world$, uwppos(f2, 1), f3len)
IF f3a$ = "" OR f3a$ = "  " THEN f3a$ = " "
f8 = LEN(world$)
IF uwppos(f2, 2) <= f8 AND uwppos(f2, 2) <> 0 THEN
   f3b$ = MID$(world$, uwppos(f2, 2), 1)
ELSE
   f3b$ = " "
END IF
f4a = FNnumber(f3a$)
f6$ = ""
FOR f5 = 1 TO uwpnum(f2)
   IF f4a >= uwpval(f2, f5, 1) AND f4a <= uwpval(f2, f5, 2) THEN
      f6$ = uwpdef$(f2, f5)
   END IF
NEXT f5
IF f6$ = "" THEN f6$ = "Unknown"
IF f3a$ = " " THEN f6$ = "Empty"
IF f3b$ <> " " THEN
   f7 = INSTR(f6$, "?")
   f8 = LEN(f6$)
   IF f7 = 1 THEN f6$ = f3b$ + RIGHT$(f6$, f8 - 1)
   IF f7 > 1 AND f8 = f7 THEN f6$ = LEFT$(f6$, f8 - 1) + f3b$
   IF f7 > 1 AND f8 <> f7 THEN
      f6a$ = LEFT$(f6$, f7 - 1)
      f6b$ = RIGHT$(f6$, f8 - f7)
      f6$ = f6a$ + f3b$ + f6b$
   END IF
END IF
FNuwp$ = f6$
END DEF

SCREEN 0
c$ = COMMAND$
REM c$ = UCASE$("gals\var1\gythios\map\p.dat 2638")
REM c$ = UCASE$("gals\var1\gythios\map\p.dat 2839")

a = INSTR(c$, " ")
IF a = 0 GOTO 10
f$ = LEFT$(c$, a - 1)
b1 = INSTR(6, f$, "\")
galdir$ = LEFT$(f$, b1)
b2 = INSTR(b1 + 7, f$, "\")
secdir$ = LEFT$(f$, b2)
parsec1$ = RIGHT$(c$, LEN(c$) - a)

IF c$ = "" THEN
10 CLS : COLOR 11
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 1000
GOTO 10000
END IF

GOSUB 5700: REM read configuration
GOSUB 5300: REM read export table
GOSUB 5450: REM read uwp data
GOSUB 5600: REM translate uwp vars to fix vars

REM read trade classification codes
FOR a = 1 TO 15
   READ tccode$(a)
NEXT a
REM read tabs
FOR a = 1 TO 8
   READ tabs(a)
NEXT a
method = 1: p1 = 1

GOSUB 2200: REM read base/allegiance info

s$ = ""
OPEN "i", 1, f$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   parsec2$ = RTRIM$(MID$(t$, 15, 4))
   IF parsec1$ = parsec2$ THEN world$ = t$
LOOP
CLOSE 1
IF world$ = "" THEN END
IF LEN(world$) < 65 THEN world$ = world$ + SPACE$(65 - LEN(world$))
oldworld$ = world$
nonworld = 0
IF MID$(oldworld$, 20, 1) = "*" THEN nonworld = 1

50 GOSUB 1500: REM show world

100 REM get input
GOSUB 1000
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND k1 >= 65 AND k1 <= 90 GOTO 110: REM A-Z
IF k2 = 0 AND k1 >= 97 AND k1 <= 122 GOTO 110: REM a-z
IF k2 = 0 AND k1 >= 48 AND k1 <= 57 GOTO 110: REM 0-9
IF k2 = 0 AND k1 = 32 OR k1 = 46 GOTO 110: REM space/.
IF k2 = 0 AND k1 = 33 GOTO 110: REM !
IF k2 = 1 AND k1 = 83 GOTO 110: REM del
IF k2 = 0 AND k1 = 35 GOTO 110: REM #
IF k2 = 0 AND k1 = 39 GOTO 110: REM '
IF k2 = 0 AND k1 = 45 GOTO 110: REM -
IF k2 = 1 AND k1 = 75 THEN GOTO 150: REM left
IF k2 = 1 AND k1 = 77 THEN GOTO 150: REM right
IF k2 = 0 AND k1 = 9 THEN GOTO 105: REM tab
IF k2 = 1 AND k1 = 15 THEN GOTO 105: REM shift-tab
IF k2 = 0 AND k1 = 8 THEN GOTO 150: REM backspace
IF k2 = 0 AND k1 = 63 GOTO 200: REM ? (help)
IF k2 = 1 AND k1 = 59 GOTO 160: REM F1 (official/homebrew)
IF k2 = 1 AND k1 = 60 GOTO 210: REM F2 (sync trade codes)
IF k2 = 1 AND k1 = 72 THEN GOTO 170: REM up
IF k2 = 1 AND k1 = 80 THEN GOTO 170: REM down
IF k2 = 1 AND k1 = 82 THEN GOTO 6000: REM ins
GOTO 100

105 REM tabs
LOCATE 5, p1 + 1: PRINT " "
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
COLOR 14: LOCATE 5, p1 + 1: PRINT "^"
GOTO 100

110 REM alpha-numeric & some
IF k1 = 83 AND k2 = 1 THEN
   k1 = 32
   sp = 1
END IF
IF p1 = 1 THEN tmp1$ = ""
IF p1 > 1 THEN tmp1$ = LEFT$(world$, p1 - 1)
IF p1 = 65 THEN tmp2$ = ""
IF p1 < 65 THEN tmp2$ = RIGHT$(world$, 65 - p1)
ok = 1
IF p1 = 1 AND k1 = 32 THEN k1 = 46
IF nonworld = 0 THEN
 FOR a = 1 TO 16
  GOSUB 130: REM check if legal
 NEXT a
END IF
IF nonworld = 1 THEN
 FOR a = 16 TO 17
  GOSUB 130: REM check if legal
 NEXT a
END IF
FOR a = 19 TO 21
 GOSUB 130: REM check if legal
NEXT a
IF p1 >= 59 AND p1 <= 61 AND k1 = 32 THEN ok = 1: REM Spaces on LRX
IF p1 = 20 THEN ok = 0
IF ok = 0 GOTO 120
IF p1 <> 27 THEN world$ = tmp1$ + CHR$(k1) + tmp2$
p1 = p1 + 1
IF sp = 1 THEN
   p1 = p1 - 1
   sp = 0
END IF
IF p1 > 65 THEN p1 = 65
IF p1 <> 27 THEN SOUND 10000, .1
120 GOTO 50

130 REM check if legal
IF a < 19 THEN
  IF p1 = fixloc(a) AND k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
END IF
IF a = 19 OR a = 20 THEN
  IF p1 = fixloc(a) AND k1 >= 65 AND k1 <= 90 THEN k1 = k1 + 32
END IF
IF p1 = fixloc(a) AND INSTR(fixed$(a), CHR$(k1)) = 0 THEN ok = 0
IF nonworld = 1 AND k1 = 120 THEN ok = 0
RETURN

150 REM left & right
LOCATE 5, p1 + 1: PRINT " "
IF k1 = 75 THEN p1 = p1 - 1
IF k1 = 8 THEN p1 = p1 - 1
IF k1 = 77 THEN p1 = p1 + 1
IF k1 = 8 AND p1 > 0 THEN
   k1 = 32
   sp = 1
END IF
IF p1 = 0 THEN p1 = 65
IF p1 = 66 THEN p1 = 1
IF k1 = 32 GOTO 110
COLOR 14: LOCATE 5, p1 + 1: PRINT "^"
GOTO 100

160 REM official/homebrew
IF nonworld = 1 GOTO 100
IF method = 1 THEN method = 3
IF method = 2 THEN method = 1
IF method = 3 THEN method = 2
SOUND 10000, .1
GOTO 50

170 REM up & down
IF p1 = 56 OR p1 = 57 GOTO 180: REM align
tmp3$ = MID$(world$, p1, 1)
ok = 0
IF nonworld = 0 THEN
   FOR a = 1 TO 16
      IF p1 = fixloc(a) THEN
         fix$ = fixed$(a)
         ok = 1
      END IF
   NEXT a
END IF
IF nonworld = 1 THEN
   FOR a = 16 TO 17
      IF p1 = fixloc(a) THEN
         fix$ = fixed$(a)
         ok = 1
      END IF
   NEXT a
END IF
FOR a = 19 TO 21
   IF p1 = fixloc(a) THEN
      fix$ = fixed$(a)
      ok = 1
   END IF
NEXT a
IF ok = 0 GOTO 50
i = INSTR(fix$, tmp3$)
l1 = LEN(fix$)
l2 = LEN(world$)
IF p1 = 1 THEN tmp1$ = ""
IF p1 > 1 THEN tmp1$ = LEFT$(world$, p1 - 1)
IF p1 = l2 THEN tmp2$ = ""
IF p1 < l2 THEN tmp2$ = RIGHT$(world$, l2 - p1)
IF k1 = 72 THEN i = i + 1
IF k1 = 80 THEN i = i - 1
IF i < 1 THEN i = l1
IF i > l1 THEN i = 1
tmp4$ = MID$(fix$, i, 1)
world$ = tmp1$ + tmp4$ + tmp2$
GOTO 190

180 REM align
tmp3$ = MID$(world$, 56, 2)
fix$ = fixed$(18)
l1 = LEN(fix$)
l2 = LEN(world$)
tmp1$ = LEFT$(world$, 55)
tmp2$ = RIGHT$(world$, 8)
i = INSTR(fix$, tmp3$)
ok = 1: IF i = 0 THEN ok = 0
IF k1 = 72 THEN i = i + 2
IF k1 = 80 THEN i = i - 2
IF ok = 0 THEN i = 1
IF i < 1 THEN i = l1 - 1
IF i >= l1 THEN i = 1
tmp4$ = MID$(fix$, i, 2)
world$ = tmp1$ + tmp4$ + tmp2$
190 SOUND 10000, .1
GOTO 50

200 REM help
SHELL "call xtra\eg help\uwpedit\uwpedit.mnu " + reader$
SCREEN 12
SCREEN 0
GOTO 50

210 REM F2 (Sync Trade Codes)
IF nonworld = 1 GOTO 100
trade$ = RTRIM$(MID$(world$, 33, 15))
GOSUB 2000: REM trade calculator
IF s1$ = trade$ THEN GOTO 50
l = LEN(s1$)
tmp$ = world$
world$ = LEFT$(tmp$, 32)
IF l <= 15 THEN world$ = world$ + s1$ + SPACE$(15 - l)
IF l > 15 THEN world$ = world$ + LEFT$(s1$, 15)
world$ = world$ + RIGHT$(tmp$, 18)
SOUND 10000, .1
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

1500 REM show star system
CLS : COLOR 10
PRINT "[Planet Name   Loc. UPP Code   B Notes           Z  PBG Al LRX *  ]"
PRINT "[-----------   ---- ---------  - --------------- -  --- -- --- -  ]"
PRINT "["; oldworld$; "]  Old"
COLOR 14
PRINT "["; LEFT$(world$, 60);
GOSUB 5100: REM double-check export
IF xpok = 0 THEN COLOR 12
PRINT MID$(world$, 61, 1);
COLOR 14
PRINT RIGHT$(world$, 4); "]  New"
LOCATE 5, p1 + 1
PRINT "^"
COLOR 11
PRINT "Method: ";
IF nonworld = 0 THEN
   IF method = 1 THEN PRINT "Official"
   IF method = 2 THEN PRINT "Homebrew"
ELSE
   PRINT "Non-World"
END IF

IF nonworld = 0 THEN
 FOR statnum = 1 TO numstats
   uwptmp$ = FNuwp$(statnum)
   IF uwptmp$ = "Empty" THEN
      COLOR 7: PRINT uwpstat$(statnum)
   ELSE
      IF statnum = 11 AND xpok = 0 THEN
         COLOR 12
      ELSE
         COLOR 11
      END IF
      PRINT uwpstat$(statnum); ": "; uwptmp$
   END IF
 NEXT statnum
END IF

GOSUB 1610: PRINT "Travel Zone: "; s1$

IF nonworld = 0 THEN
 PRINT "Bases: ";
 FOR a = 1 TO basalgn(1)
   IF basalg$(1, a, 1) = MID$(world$, 31, 1) THEN
      PRINT basalg$(1, a, 2)
   END IF
 NEXT a
END IF

PRINT "Allegiance: ";
FOR a = 1 TO basalgn(2)
   IF basalg$(2, a, 1) = MID$(world$, 56, 2) THEN
      PRINT basalg$(2, a, 2)
   END IF
NEXT a

IF nonworld = 1 THEN
 PRINT "Marker: ";
 a = VAL(MID$(world$, 21, 1))
 SELECT CASE a
  CASE 1
   PRINT "Triangle"
  CASE 2
   PRINT "Square"
  CASE 3
   PRINT "Diamond"
  CASE 4
   PRINT "Lots-o-Dots"
  CASE ELSE
   PRINT "Unknown"
 END SELECT
END IF

IF nonworld = 0 THEN
 GOSUB 2000
 IF LEN(s1$) > 15 THEN s1$ = LEFT$(s1$, 15)
 COLOR 12: LOCATE 6, 33: PRINT "["; s1$
 LOCATE 6, 49: PRINT "] Computed Trade Codes"
END IF

GOSUB 5000: REM instruction box
RETURN

1610 REM zone
s$ = MID$(world$, 49, 1)
IF s$ = " " OR s$ = "G" THEN s1$ = "Green"
IF s$ = "A" THEN s1$ = "Amber"
IF s$ = "R" THEN s1$ = "Red"
IF s$ = "B" THEN s1$ = "Blue"
RETURN

2000 REM trade classification calculator
size = fnnum(MID$(world$, 21, 1))
atmos = fnnum(MID$(world$, 22, 1))
hydro = fnnum(MID$(world$, 23, 1))
popul = fnnum(MID$(world$, 24, 1))
govern = fnnum(MID$(world$, 25, 1))
law = fnnum(MID$(world$, 26, 1))
REM we first assume they all apply
FOR j = 1 TO 15
   tc(j) = 1
NEXT j
REM now we attempt to exclude each in turn
REM 1. Ag
IF atmos < 4 OR atmos > 9 THEN tc(1) = 0
IF hydro < 4 THEN tc(1) = 0
IF method = 1 AND hydro > 8 THEN tc(1) = 0: REM offical only
IF popul < 5 OR popul > 7 THEN tc(1) = 0
REM 2. As
IF size <> 0 OR atmos <> 0 OR hydro <> 0 THEN tc(2) = 0
REM 3. Ba
IF popul <> 0 OR govern <> 0 OR law <> 0 THEN tc(3) = 0
REM 4. De
IF atmos < 2 OR hydro <> 0 THEN tc(4) = 0
IF method = 1 THEN
   REM 5. Fl (according to errata)
   IF atmos < 10 OR hydro = 0 THEN tc(5) = 0
END IF
IF method = 2 THEN
   REM 5. Fl (variant)
   IF atmos < 10 OR atmos > 12 OR hydro = 0 THEN tc(5) = 0
END IF
REM 6. Hi
IF popul < 9 THEN tc(6) = 0
REM 7. Ic
IF atmos > 1 OR hydro = 0 THEN tc(7) = 0
REM 8. In
IF atmos < 2 OR atmos = 5 THEN tc(8) = 0
IF atmos = 6 OR atmos = 8 THEN tc(8) = 0
IF atmos > 9 OR popul < 9 THEN tc(8) = 0
REM 9. Lo
IF popul > 3 THEN tc(9) = 0
REM 10. Na
IF atmos > 3 OR hydro > 3 OR popul < 6 THEN tc(10) = 0
REM 11. Ni
IF popul > 6 THEN tc(11) = 0
REM 12. Po
IF atmos < 2 OR atmos > 5 THEN tc(12) = 0
IF hydro > 3 THEN tc(12) = 0
REM 13. Ri
IF atmos <> 6 AND atmos <> 8 THEN tc(13) = 0
IF popul < 6 OR popul > 8 THEN tc(13) = 0
IF govern < 4 OR govern > 9 THEN tc(13) = 0
REM 14. Va
IF atmos <> 0 THEN tc(14) = 0
IF tc(2) = 1 THEN tc(14) = 0
REM 15. Wa
IF hydro < 10 THEN tc(15) = 0
REM variant / ditch rich, poor, ind, ni, & na
IF method = 2 THEN
   tc(13) = 0: REM rich
   tc(12) = 0: REM poor
   tc(8) = 0: REM industrial
   tc(11) = 0: REM nonindustrial
   tc(10) = 0: REM nonagricultural
END IF
REM now compose trade string
s1$ = ""
FOR j = 1 TO 15
   IF tc(j) = 1 THEN s1$ = s1$ + tccode$(j) + " "
NEXT j
IF s1$ <> "" THEN s1$ = RTRIM$(s1$)
RETURN

2200 REM get base/allegiance info
g$ = LEFT$(f$, INSTR(f$, "\MAP") - 1)
h$ = RIGHT$(g$, LEN(g$) - INSTR(6, g$, "\"))
sector$ = g$ + "\" + h$ + ".dat"
OPEN "i", 1, sector$
FOR a = 1 TO 19
 LINE INPUT #1, t$
NEXT a
fixed$(15) = "": fixed$(18) = ""
j = 1
2244 REM get base & status info
i = 0
LINE INPUT #1, basalg$(j, i, 0)
i = 1
2245 IF EOF(1) = -1 GOTO 2246
LINE INPUT #1, temp$
IF temp$ = "" GOTO 2246
t9 = LEN(temp$)
IF j = 1 THEN
   basalg$(1, i, 1) = LEFT$(temp$, 1)
   fixed$(15) = fixed$(15) + LEFT$(temp$, 1)
   basalg$(1, i, 2) = RTRIM$(RIGHT$(temp$, t9 - 4))
END IF
IF j = 2 THEN
   algncol(i) = VAL(LEFT$(temp$, 2))
   basalg$(2, i, 1) = MID$(temp$, 4, 2)
   fixed$(18) = fixed$(18) + MID$(temp$, 4, 2)
   basalg$(2, i, 2) = RTRIM$(RIGHT$(temp$, t9 - 8))
END IF
i = i + 1
GOTO 2245
2246 basalgn(j) = i - 1
IF j = 2 GOTO 2248
j = j + 1
GOTO 2244
2248 CLOSE 1
REM invert base string
tmp$ = fixed$(15): l = LEN(tmp$)
fixed$(15) = ""
FOR a = l TO 1 STEP -1
   fixed$(15) = fixed$(15) + MID$(tmp$, a, 1)
NEXT a
REM invert allegiance string
tmp$ = fixed$(18): l = LEN(tmp$) / 2
fixed$(18) = ""
FOR a = l TO 1 STEP -1
   fixed$(18) = fixed$(18) + MID$(tmp$, a * 2 - 1, 2)
NEXT a
RETURN

5000 REM instruction box
LOCATE 8, 40: COLOR 9
PRINT CHR$(218); STRING$(30, 196); CHR$(191)
LOCATE 21, 40
PRINT CHR$(192); STRING$(30, 196); CHR$(217)
z$(2) = "  ? = Help"
z$(3) = CHR$(27) + "/" + CHR$(26) + " = Movement"
z$(4) = CHR$(24) + "/" + CHR$(25) + " = Stat Adjustment"
z$(5) = " F1 = Method Toggle"
z$(6) = " F2 = Sync Trade Codes"
IF nonworld = 1 THEN
  z$(5) = "": z$(6) = ""
END IF
z$(8) = "  Use other keys to edit"
z$(10) = "Ins = Save & Quit"
z$(11) = "Esc = Exit Without Saving"
FOR a = 9 TO 20
   COLOR 9
   LOCATE a, 40: PRINT CHR$(179)
   LOCATE a, 71: PRINT CHR$(179)
   COLOR 13
   LOCATE a, 43: PRINT z$(a - 8)
NEXT a
RETURN

5100 REM double-check export code
xpok = 1
export$ = MID$(world$, 61, 1)
FOR a = 1 TO 34
   IF export$ = excode$(1, a) THEN
      mintech = extech(a)
      etc$ = exetc$(a)
   END IF
NEXT a
REM minimum tech exclusion
tech = fnnum(MID$(world$, 28, 1))
IF tech < mintech THEN xpok = 0
REM non-agro exclusion
GOSUB 2000
agro = INSTR(s1$, "Ag")
IF etc$ = "A" AND agro = 0 THEN xpok = 0
REM low-life exclusion
life = fnnum(MID$(world$, 59, 1))
IF etc$ = "L" AND life < 7 THEN xpok = 0
RETURN

5300 REM read export table
OPEN "i", 1, "data\export.dat"
FOR a = 1 TO 3
   LINE INPUT #1, t$
NEXT a
FOR a = 1 TO 34
   LINE INPUT #1, t$
   excode$(1, a) = MID$(t$, 6, 1)
   excode$(2, a) = RTRIM$(MID$(t$, 8, 23))
   extech(a) = FNnumber(MID$(t$, 31, 1))
   exetc$(a) = RIGHT$(t$, 1)
NEXT a
CLOSE 1
RETURN

5450 REM read in galaxy's uwp codes
OPEN "i", 1, galdir$ + "uwp.dat"
t$ = ""
a = 0: b = 0
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LTRIM$(t$) <> "" AND LEFT$(t$, 1) <> "#" THEN
      c = INSTR(t$, "=")
      IF c = 0 THEN
         IF a > 0 THEN uwpnum(a) = b
         a = a + 1: b = 0
         uwpstat$(a) = t$
      END IF
      IF LEFT$(t$, 4) = "pos=" THEN
         uwppos(a, 1) = VAL(MID$(t$, 5, 2))
         IF LEN(t$) > 6 THEN
            uwppos(a, 2) = VAL(MID$(t$, 8, 2))
         ELSE
            uwppos(a, 2) = 0
         END IF
         IF LEN(t$) > 9 THEN
            uwppos(a, 3) = VAL(MID$(t$, 11, 2))
         ELSE
            uwppos(a, 3) = 0
         END IF
      END IF
      IF c <> 0 AND LEFT$(t$, 4) <> "pos=" THEN
         b = b + 1
         tmp$ = RTRIM$(LTRIM$(LEFT$(t$, c - 1)))
         IF LEN(tmp$) < 3 THEN
            uwpval(a, b, 1) = FNnumber(tmp$)
            uwpval(a, b, 2) = uwpval(a, b, 1)
         ELSE
            uwpval(a, b, 1) = FNnumber(LEFT$(tmp$, 1))
            uwpval(a, b, 2) = FNnumber(RIGHT$(tmp$, 1))
         END IF
         uwpdef$(a, b) = RTRIM$(LTRIM$(RIGHT$(t$, LEN(t$) - c)))
      END IF
   END IF
LOOP
uwpnum(a) = b
numstats = a
CLOSE 1
5460 REM read in sector's uwp amendments
REM check if file exists
OPEN "r", 1, secdir$ + "uwp.dat"
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN SHELL "erase " + secdir$ + "uwp.dat"
IF exist = 0 THEN RETURN
OPEN "i", 1, secdir$ + "uwp.dat"
t$ = ""
first = 1
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LTRIM$(t$) <> "" AND LEFT$(t$, 1) <> "#" THEN
      c = INSTR(t$, "=")
      IF c = 0 THEN
         IF first = 0 THEN uwpnum(a) = b
         IF first = 1 THEN first = 0
         a = 0
         FOR b1 = 1 TO numstats
            IF t$ = uwpstat$(b1) THEN a = b1
         NEXT b1
         IF a = 0 THEN
            CLS
            PRINT "Error: ";
            PRINT t$; " not defined in "; galdir$ + "uwp.dat"
            END
         END IF
         b = uwpnum(a)
      END IF
      IF c <> 0 THEN
         b = b + 1
         tmp$ = RTRIM$(LTRIM$(LEFT$(t$, c - 1)))
         IF LEN(tmp$) < 3 THEN
            uwpval(a, b, 1) = FNnumber(tmp$)
            uwpval(a, b, 2) = uwpval(a, b, 1)
         ELSE
            uwpval(a, b, 1) = FNnumber(LEFT$(tmp$, 1))
            uwpval(a, b, 2) = FNnumber(RIGHT$(tmp$, 1))
         END IF
         uwpdef$(a, b) = RTRIM$(LTRIM$(RIGHT$(t$, LEN(t$) - c)))
      END IF
   END IF
LOOP
uwpnum(a) = b
CLOSE 1
RETURN

5500 REM egacolor gold on blue
SHELL "call xtra\egacolor 00 10"
SHELL "call xtra\egacolor 07 46"
RETURN

5600 REM translate uwpvars to fixvars
FOR a = 1 TO 13
   fixloc(a) = uwppos(a, 1)
   fixed$(a) = ""
   FOR b = 1 TO uwpnum(a)
      FOR c = uwpval(a, b, 1) TO uwpval(a, b, 2)
         IF INSTR(fixed$(a), FNletter$(c)) = 0 THEN
            fixed$(a) = fixed$(a) + FNletter$(c)
         END IF
      NEXT c
   NEXT b
NEXT a
fixloc(14) = 52: REM popmult
fixed$(14) = "0123456789"
fixloc(15) = 31: REM base
fixloc(16) = 49: REM zone
fixed$(16) = " ABR"
fixloc(17) = 21: REM marker (nonworlds)
fixed$(17) = "1234"
fixloc(19) = 63: REM menu/file
fixed$(19) = " mf"
fixloc(20) = 64: REM hexworld/sysmap
fixed$(20) = " xyz"
fixloc(21) = 65: REM hide
fixed$(21) = " hH"
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
SHELL "copy " + f$ + " subsec.tmp"
OPEN "i", 1, "subsec.tmp"
OPEN "o", 2, f$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF RTRIM$(oldworld$) = RTRIM$(t$) THEN t$ = RTRIM$(world$)
   PRINT #2, t$
LOOP
CLOSE 1
CLOSE 2
SHELL "erase subsec.tmp"
GOTO 10000

REM trade classification data
DATA "Ag","As","Ba","De","Fl","Hi","Ic","In"
DATA "Lo","Na","Ni","Po","Ri","Va","Wa"

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

