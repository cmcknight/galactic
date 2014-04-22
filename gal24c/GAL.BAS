
REM Galactic v2.4c
REM Public Domain 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com
REM Written in Microsoft QuickBasic version 4.5

DIM subname$(16, 2)
DIM world$(80)
DIM basalg$(2, 50, 2)
DIM basalgn(2)
DIM algncol(50)
DIM letimage(13, 44) AS INTEGER
DIM length(44)
DIM jump%(300, 5)
DIM subtxt%(16)
DIM colors$(15)
DIM uwpstat$(15): REM stat names
DIM uwpnum%(15): REM number of definitions per stat
DIM uwppos%(15, 3): REM positions (main & mod) & color
DIM uwpdef$(15, 40): REM value definitions
DIM uwpval%(15, 40, 2): REM low & high values for each def
DIM nhook%(3)
DIM hooke%(3, 20)
DIM hookac%(3, 20)
DIM hookcom$(3, 20)
DIM hookspec$(3, 20)
DIM hookvar$(9)
DIM hookval$(9)
DIM gals$(15, 2)
DIM xx(500)
DIM yy(500)
DIM col(500)
DIM sec$(500, 2)
DIM pr$(3)

ON ERROR GOTO 9900
RANDOMIZE INT(TIMER / 2)

DEF FNxstr$ (f21) = LTRIM$(STR$(f21))

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
IF uwpval%(f2, 1, 1) > 1000 THEN f3len = 2
f3a$ = MID$(world$(ref), uwppos%(f2, 1), f3len)
IF f3a$ = "" OR f3a$ = "  " THEN f3a$ = " "
f8 = LEN(world$(ref))
IF uwppos%(f2, 2) <= f8 AND uwppos%(f2, 2) <> 0 THEN
   f3b$ = MID$(world$(ref), uwppos%(f2, 2), 1)
ELSE
   f3b$ = " "
END IF
f4a = FNnumber(f3a$)
f6$ = ""
FOR f5 = 1 TO uwpnum%(f2)
   IF f4a >= uwpval%(f2, f5, 1) AND f4a <= uwpval%(f2, f5, 2) THEN
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

DEF FNhook$ (f21$)
hookval$(1) = reader$
hookval$(2) = editor$
hookval$(3) = galdir$
hookval$(4) = secdir$
hookval$(5) = seclist$
hookval$(6) = secfp$
hookval$(7) = fsub$
hookval$(8) = sublet$
hookval$(9) = coord$
FOR f5 = 1 TO 9
   l = LEN(f21$)
   f22 = INSTR(f21$, hookvar$(f5))
   IF f22 > 0 THEN
      l2 = LEN(hookvar$(f5))
      f23$ = LEFT$(f21$, f22 - 1)
      f24$ = RIGHT$(f21$, l - f22 - l2 + 1)
      f21$ = f23$ + hookval$(f5) + f24$
   END IF
NEXT f5
FNhook$ = f21$
END DEF

DEF FNsec (f3x, f3y)
f30 = 0
FOR f31 = 1 TO numsec
   IF f3x = xx(f31) AND f3y = yy(f31) THEN f30 = f31
NEXT f31
FNsec = f30
END DEF

fp1 = 1: fp2 = 1: fp3old = 13
FOR a = 1 TO 9: READ hookvar$(a): NEXT a

GOSUB 5200: REM calculate video stuff
GOSUB 5550: REM read names of 15 colors for insert jumproute query
GOSUB 5800: REM read hooks

5 REM startover
GOSUB 5715: REM read gal.cfg
GOSUB 5000: REM read letters.dat -> image data

10 REM front page
SCREEN 0: CLS : COLOR 14
SHELL "sub\funky data\title.dat"

PRINT
COLOR 11
PRINT "      Starmaps"
PRINT "      About this Program"
PRINT
PRINT "      Select Text Editor     ";
COLOR 13: PRINT "("; editor$; ")"
COLOR 11: PRINT "      Select Text Reader     ";
COLOR 13: PRINT "("; reader$; ")"
COLOR 11: PRINT "      Foreground/Background  ";
COLOR 13
SELECT CASE clrmode
 CASE 1:
  PRINT "(colors on black)"
 CASE 2:
  PRINT "(colors on white)"
 CASE 3:
  PRINT "(white on black)"
 CASE 4:
  PRINT "(black on white)"
END SELECT
COLOR 11
PRINT
PRINT "      Quit"
COLOR 9
PRINT
PRINT "Traveller is a registered trademark of Far Future Enterprises."
PRINT "Portions of this software are Copyright 1977-1998 Far Future ";
PRINT "Enterprises."

14 REM arrow
LOCATE fp3old, 3
PRINT "  "
IF fp1 = 1 THEN fp3 = 13
IF fp1 = 2 THEN fp3 = 14
IF fp1 = 3 THEN fp3 = 16
IF fp1 = 4 THEN fp3 = 17
IF fp1 = 5 THEN fp3 = 18
IF fp1 = 6 THEN fp3 = 20
fp3old = fp3
COLOR 12
LOCATE fp3, 3
PRINT CHR$(196); CHR$(26)

15 REM get input
GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND k1 = 81 GOTO 10000: REM Q 6,1
IF k2 = 1 AND (k1 = 75 OR k1 = 77) GOTO 17: REM left/right
IF k2 = 1 AND (k1 = 72 OR k1 = 80) GOTO 17: REM up/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 17: REM pgup/pgdn
IF k2 = 0 AND k1 = 13 GOTO 18: REM enter
GOTO 15

17 REM up/down/pgup/pgdn
IF k1 = 72 OR k1 = 75 THEN fp1 = fp1 - 1
IF k1 = 80 OR k1 = 77 THEN fp1 = fp1 + 1
IF k1 = 73 THEN fp1 = 1
IF k1 = 81 THEN fp1 = 0
IF fp1 = 0 THEN fp1 = 6
IF fp1 = 7 THEN fp1 = 1
SOUND 10000, .1
GOTO 14

18 REM enter
IF fp1 = 1 GOTO 30
IF fp1 = 2 GOTO 19
IF fp1 >= 3 AND fp1 <= 5 GOTO 20
IF fp1 = 6 GOTO 10000

19 REM Help #1
SHELL "xtra\eg help\help.mnu " + reader$
GOTO 10

20 REM change settings
IF fp1 = 3 THEN SHELL "sub\cfg 1"
IF fp1 = 4 THEN SHELL "sub\cfg 2"
IF fp1 = 5 THEN SHELL "sub\cfg 3"
GOTO 5

30 REM select galaxy
GOSUB 5750: REM read galaxy list
GOSUB 5720: REM read gals\where.dat
GOTO 5760

40 REM get sector data
IF nosector = 1 GOTO 10
GOSUB 2200

50 REM draw subsector boxes
SCREEN 0
COLOR 2
hhex = 101
trip = 1
CLS
LOCATE 1, 1: PRINT CHR$(201);
LOCATE 21, 61: PRINT CHR$(188);
LOCATE 1, 61: PRINT CHR$(187);
LOCATE 21, 1: PRINT CHR$(200);
FOR i = 16 TO 46 STEP 15
LOCATE 1, i: PRINT CHR$(203);
LOCATE 21, i: PRINT CHR$(202);
NEXT i
FOR i = 6 TO 16 STEP 5
LOCATE i, 1: PRINT CHR$(204);
LOCATE i, 61: PRINT CHR$(185);
NEXT i
FOR i = 16 TO 46 STEP 15
FOR j = 6 TO 16 STEP 5
LOCATE j, i: PRINT CHR$(206);
NEXT j
NEXT i
FOR i = 1 TO 46 STEP 15
FOR j = 1 TO 14
FOR k = 1 TO 21 STEP 5
LOCATE k, i + j: PRINT CHR$(205);
NEXT k
NEXT j
NEXT i
FOR i = 1 TO 16 STEP 5
FOR j = 1 TO 4
FOR k = 1 TO 61 STEP 15
LOCATE i + j, k: PRINT CHR$(186);
NEXT k
NEXT j
NEXT i

REM fill in subsector names
COLOR 14
FOR i = 1 TO 4
FOR j = 1 TO 4
k = j + ((i - 1) * 4)
lname = LEN(subname$(k, 1))
csubname$ = subname$(k, 1)
IF lname > 14 THEN csubname$ = LEFT$(subname$(k, 1), 14)
IF lname > 14 THEN lname = 14
LOCATE ((i - 1) * 5) + 3, ((j - 1) * 15) + 8 - INT((lname - 1) / 2)
PRINT csubname$;
NEXT j
NEXT i
LOCATE 23, 31 - INT(LEN(secname$) / 2)
PRINT secname$;
LOCATE 25, 70: COLOR 12: PRINT "? = Help";

60 REM make inner box and get instructions
tx = ((zj - 1) * 15) + 2
ty = ((zi - 1) * 5) + 2
COLOR 13
LOCATE ty, tx: PRINT CHR$(218);
LOCATE ty, tx + 13: PRINT CHR$(191);
LOCATE ty + 2, tx: PRINT CHR$(192);
LOCATE ty + 2, tx + 13: PRINT CHR$(217);
FOR i = tx + 1 TO tx + 12
LOCATE ty, i: PRINT CHR$(196);
LOCATE ty + 2, i: PRINT CHR$(196);
NEXT i
k = zj + ((zi - 1) * 4)
lname = LEN(subname$(k, 1))
IF lname < 13 THEN
   LOCATE ty + 1, tx
   PRINT CHR$(179);
END IF
IF lname < 14 THEN
   LOCATE ty + 1, tx + 13
   PRINT CHR$(179);
END IF
GOSUB 900
tx = ((zj - 1) * 15) + 2
ty = ((zi - 1) * 5) + 2
LOCATE ty, tx: PRINT CHR$(32);
LOCATE ty, tx + 13: PRINT CHR$(32);
LOCATE ty + 2, tx: PRINT CHR$(32);
LOCATE ty + 2, tx + 13: PRINT CHR$(32);
FOR i = tx + 1 TO tx + 12
LOCATE ty, i: PRINT CHR$(32);
LOCATE ty + 2, i: PRINT CHR$(32);
NEXT i
k = zj + ((zi - 1) * 4)
lname = LEN(subname$(k, 1))
IF lname < 13 THEN
   LOCATE ty + 1, tx
   PRINT CHR$(32);
END IF
IF lname < 14 THEN
   LOCATE ty + 1, tx + 13
   PRINT CHR$(32);
END IF
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 1 AND k1 = 72 THEN GOSUB 65: REM up
IF k2 = 0 AND k1 = 75 THEN GOSUB 65: REM k
IF k2 = 1 AND k1 = 80 THEN GOSUB 70: REM down
IF k2 = 0 AND k1 = 74 THEN GOSUB 70: REM j
IF k2 = 1 AND k1 = 75 THEN GOSUB 75: REM left
IF k2 = 0 AND k1 = 72 THEN GOSUB 75: REM h
IF k2 = 1 AND k1 = 77 THEN GOSUB 80: REM right
IF k2 = 0 AND k1 = 76 THEN GOSUB 80: REM l
IF k2 = 1 AND k1 = 73 THEN zi = 1: REM pgup
IF k2 = 1 AND k1 = 81 THEN zi = 4: REM pgdn
IF k2 = 0 AND k1 = 9 THEN zj = 4: REM fwd tab
IF k2 = 1 AND k1 = 15 THEN zj = 1: REM back tab
IF k2 = 0 AND k1 = 27 THEN GOTO 3000: REM esc
IF k2 = 0 AND k1 = 81 GOTO 3000: REM q
IF k2 = 0 AND k1 = 13 THEN GOTO 90: REM enter
IF k2 = 0 AND k1 = 32 THEN GOTO 90: REM space
catch = 0: REM hook catching
FOR tmp = 1 TO nhook%(2)
   IF k2 = hooke%(2, tmp) AND k1 = hookac%(2, tmp) THEN catch = tmp
NEXT tmp
IF catch > 0 GOTO 62
GOTO 60

62 REM hook caught
zk = zj + ((zi - 1) * 4)
fsub$ = mapdir$ + subname$(zk, 2)
CLS
IF INSTR(hookspec$(2, catch), "E") > 0 THEN GOSUB 5500
GOSUB 5727: REM write position
SHELL FNhook$(hookcom$(2, catch))
IF INSTR(hookspec$(2, catch), "U") > 0 THEN GOSUB 5450
IF INSTR(hookspec$(2, catch), "P") > 0 THEN GOSUB 3900
SCREEN 12: hhex = hex: trip = 1
GOTO 40

65 REM up
zi = zi - 1
IF zi = 0 THEN
   IF north$ = "<nil>" THEN zi = 1
   IF north$ <> "<nil>" THEN
      zi = 4: newjy = newjy + 4: ynow = ynow - 1
      GOSUB 5710: GOTO 40
   END IF
END IF
RETURN

70 REM down
zi = zi + 1
IF zi = 5 THEN
   IF south$ = "<nil>" THEN zi = 4
   IF south$ <> "<nil>" THEN
      zi = 1: newjy = newjy - 4: ynow = ynow + 1
      GOSUB 5710: GOTO 40
   END IF
END IF
RETURN

75 REM left
zj = zj - 1
IF zj = 0 THEN
   IF west$ = "<nil>" THEN zj = 1
   IF west$ <> "<nil>" THEN
      zj = 4: newjx = newjx + 4: xnow = xnow - 1
      GOSUB 5710: GOTO 40
   END IF
END IF
RETURN

80 REM right
zj = zj + 1
IF zj = 5 THEN
   IF east$ = "<nil>" THEN zj = 4
   IF east$ <> "<nil>" THEN
      zj = 1: newjx = newjx - 4: xnow = xnow + 1
      GOSUB 5710: GOTO 40
   END IF
END IF
RETURN

90 REM goto subsector screen
zk = zj + ((zi - 1) * 4)
fsub$ = mapdir$ + subname$(zk, 2)

100 REM get subsector
jumps = 0
FOR i = 1 TO 80
world$(i) = ""
NEXT i
OPEN "i", 1, fsub$
110 LINE INPUT #1, t4$
t4$ = LTRIM$(RTRIM$(t4$))
IF t4$ = "" GOTO 115
t3$ = LEFT$(t4$, 1)
IF (t3$ = "@" OR t3$ = "#") THEN GOTO 115
IF t3$ = "$" THEN
   jumps = jumps + 1
   rhex = VAL(MID$(t4$, 2, 4)): GOSUB 1100
   jump%(jumps, 1) = hex
   rhex = VAL(MID$(t4$, 7, 4)): GOSUB 1100
   jump%(jumps, 2) = hex
   jump%(jumps, 3) = VAL(MID$(t4$, 12, 2))
   place = 14
   IF jump%(jumps, 3) = -1 THEN place = place + 1
   jump%(jumps, 4) = VAL(MID$(t4$, place, 2))
   place = place + 2
   IF jump%(jumps, 4) = -1 THEN place = place + 1
   jump%(jumps, 5) = VAL(MID$(t4$, place, 2))
   IF jump%(jumps, 5) = 0 THEN jump%(jumps, 5) = 11
   GOTO 115
END IF
rhex = VAL(MID$(t4$, 15, 4))
GOSUB 1100
GOSUB 1150
world$(ref) = t4$
115 IF EOF(1) = -1 GOTO 120
GOTO 110
120 CLOSE 1

150 REM goto graphics mode
CLS
SCREEN 12
GOSUB 6000: REM set palette according to clrmode

151 REM draw subsector map
CLS
REM draw blue hexs
COLOR 1
FOR a = 1 TO 8
FOR b = 1 TO 10
hex = (a * 100) + b
GOSUB 500
NEXT b
NEXT a
REM draw red hexs
COLOR 4
FOR a = 1 TO 8
FOR b = 1 TO 10
hex = (a * 100) + b
c = ((a - 1) * 10) + b
tmp$ = MID$(world$(c), 63, 1)
tmp2$ = MID$(world$(c), 64, 1)
IF LTRIM$(tmp$ + tmp2$) <> "" THEN GOSUB 500
NEXT b
NEXT a
REM draw jumproutes
IF jumps > 0 THEN
   FOR a = 1 TO jumps
      hex = jump%(a, 1): GOSUB 600
      p1 = cent1 + yank: p2 = cent2
      hex = jump%(a, 2): GOSUB 600
      p3 = cent1 + yank: p4 = cent2
      IF jump%(a, 3) <> 0 THEN
         p3 = p3 + (jump%(a, 3) * chexa * 12)
      END IF
      IF jump%(a, 4) <> 0 THEN
         p4 = p4 + (jump%(a, 4) * chexb * 20)
      END IF
      LINE (p1, p2)-(p3, p4), jump%(a, 5), , &H8888
   NEXT a
END IF
REM fill in map
FOR ref = 1 TO 80
IF LEN(world$(ref)) = 0 GOTO 155
l = ASC(MID$(world$(ref), 20, 1)) - 64
IF l = 24 THEN l = 6
GOSUB 1175
GOSUB 700
155 NEXT ref
REM subsector/sector name
COLOR 11
bottom$ = subname$(zk, 1) + "/" + secname$
l = LEN(bottom$)
LOCATE 29, 60 - INT(l / 2)
PRINT bottom$;

IF trip = 1 THEN
   hex = hhex
   trip = 0
END IF
GOSUB 800
GOTO 210
200 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 1 AND k1 = 72 GOTO 1000: REM up
IF k2 = 0 AND k1 = 75 GOTO 1000: REM k
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 1010: REM pgup/pgdn
IF k2 = 0 AND k1 = 9 GOTO 1010: REM fwd tab
IF k2 = 1 AND k1 = 15 GOTO 1010: REM back tab
IF k2 = 1 AND k1 = 80 GOTO 1020: REM down
IF k2 = 0 AND k1 = 74 GOTO 1020: REM j
IF k2 = 1 AND k1 = 75 GOTO 1040: REM left
IF k2 = 0 AND k1 = 72 GOTO 1040: REM h
IF k2 = 1 AND k1 = 77 GOTO 1060: REM right
IF k2 = 0 AND k1 = 76 GOTO 1060: REM l
IF k2 = 0 AND k1 = 27 GOTO 50: REM esc
IF k2 = 0 AND k1 = 81 GOTO 50: REM q
IF k2 = 0 AND k1 = 13 GOTO 2000: REM enter
IF k2 = 0 AND k1 = 32 GOTO 2000: REM space
IF k2 = 0 AND k1 = 62 GOTO 2000: REM >
IF k2 = 0 AND k1 = 85 GOTO 315: REM u
IF k2 = 0 AND k1 = 12 GOTO 290: REM ctrl-l
IF k2 = 0 AND k1 = 21 GOTO 295: REM ctrl-u
IF k2 = 1 AND (k1 = 59 OR k1 = 60) GOTO 330: REM F1/F2
IF k2 = 1 AND k1 = 62 GOTO 425: REM F4
IF k2 = 1 AND k1 = 64 GOTO 460: REM F6
IF k2 = 1 AND k1 = 66 GOTO 430: REM F8
IF k2 = 1 AND k1 = 83 GOTO 440: REM delete
catch = 0: REM hook catching
FOR tmp = 1 TO nhook%(3)
   IF k2 = hooke%(3, tmp) AND k1 = hookac%(3, tmp) THEN catch = tmp
NEXT tmp
IF catch > 0 GOTO 205
GOTO 210

205 REM hook caught
IF INSTR(hookspec$(3, catch), "1") > 0 AND world$(ref) = "" GOTO 200
IF INSTR(hookspec$(3, catch), "0") > 0 AND world$(ref) <> "" GOTO 200
IF INSTR(hookspec$(3, catch), "E") > 0 THEN
   SCREEN 0: GOSUB 5500
END IF
GOSUB 5727: REM write position
SHELL FNhook$(hookcom$(3, catch))
IF INSTR(hookspec$(3, catch), "U") > 0 THEN GOSUB 5450
IF INSTR(hookspec$(3, catch), "C") > 0 THEN
   GOSUB 3900: REM reload positional info
   GOSUB 2200: REM reload sector
END IF
SCREEN 12: hhex = hex: trip = 1
GOTO 90

210 GOSUB 1150: REM get ref#
COLOR 14
hw$ = MID$(world$(ref), 64, 1)
hidden$ = MID$(world$(ref), 65, 1)
hidden = 0: nonworld = 0: noname = 0
IF hidden$ = "h" THEN hidden = 1
IF hidden$ = "H" THEN hidden = 2
IF MID$(world$(ref), 20, 1) = "*" THEN nonworld = 1
IF RTRIM$(LEFT$(world$(ref), 14)) = "." THEN noname = 1
IF LEN(world$(ref)) = 0 OR (hidden = 2 AND nonworld = 1) THEN
   GOSUB 1200: REM empty hex
ELSE
   GOSUB 1250: REM non-empty hex
END IF
GOTO 200

290 REM redraw subsector
trip = 1: hhex = hex
GOTO 151

295 REM uwp toggle
IF uwptog = 0 THEN uwptog = 1 ELSE uwptog = 0
GOTO 290

315 REM sector-level uwp.dat
tmp$ = secdir$ + "\uwp.dat"
OPEN "r", 1, tmp$
exist = LOF(1)
CLOSE 1
IF exist <> 0 GOTO 318
GOSUB 5640
316 GOSUB 900
IF k2 = 1 GOTO 316
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 27 OR k1 = 81 OR k1 = 78 GOTO 290: REM esc/q/n
IF k1 = 89 GOTO 317: REM y
GOTO 316
317 SHELL "copy classic\beyond\uwp.dat " + tmp$
318 SCREEN 0
GOSUB 5500: REM egacolor
SHELL editor$ + " " + tmp$
GOSUB 5450: REM read uwp.dat
SCREEN 12: GOTO 290

330 REM view/edit subsector write-up
IF subtxt%(zk) = 0 AND k1 = 59 THEN GOTO 200
newfile = 0
IF k1 = 59 THEN app$ = reader$
IF k1 = 60 THEN app$ = editor$
txtsub$ = locdir$ + "sub-" + CHR$(zk + 64)
IF subtxt%(zk) <> 0 GOTO 350
newfile = 1
tmp$ = "subsector"
GOSUB 5600: REM mini-menu
335 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 70 GOTO 340: REM f
IF k2 = 0 AND k1 = 77 GOTO 345: REM m
IF k2 = 0 AND k1 = 27 GOTO 290: REM esc
IF k2 = 0 AND k1 = 81 GOTO 290: REM q
GOTO 335
340 subtxt%(zk) = 1: abv$ = "f"
GOTO 350
345 subtxt%(zk) = 2: abv$ = "m"
350 IF subtxt%(zk) = 1 THEN txtsub$ = txtsub$ + ".txt"
IF subtxt%(zk) = 2 THEN txtsub$ = txtsub$ + ".mnu"
SCREEN 0
GOSUB 5500: REM egacolor
IF subtxt%(zk) = 1 AND newfile = 0 THEN
   SHELL app$ + " " + txtsub$
END IF
IF subtxt%(zk) = 2 AND newfile = 0 THEN
   SHELL "xtra\eg " + txtsub$ + " " + app$
END IF
IF subtxt%(zk) = 1 AND newfile = 1 THEN
   GOSUB 400: REM insert abv$ into sector file
   REM set up initial subsector text file
   f$ = txtsub$
   REM check if file f$ exists
   OPEN "r", 1, f$
   exist = LOF(1)
   CLOSE 1
   IF exist = 0 THEN
      OPEN "o", 1, txtsub$
      tmp$ = subname$(zk, 1) + " Subsector"
      PRINT #1, ""
      PRINT #1, tmp$
      PRINT #1, STRING$(LEN(tmp$), "-")
      PRINT #1, ""
      CLOSE 1
   END IF: REM exist=0
   REM go into subsector text file
   SHELL app$ + " " + txtsub$
   GOTO 394
END IF
IF subtxt%(zk) = 2 AND newfile = 1 THEN
   GOSUB 400: REM insert abv$ into sector file
   REM set up initial subsector menu file
   f$ = txtsub$
   f1$ = "sub-" + CHR$(zk + 64)
   REM check if file f$ exists
   OPEN "r", 1, f$
   exist = LOF(1)
   CLOSE 1
   IF exist = 0 THEN
      SHELL "erase " + f$
      OPEN "o", 1, f$
      OPEN "i", 2, "data\starter2.mnu"
      PRINT #1, "@dir=" + locdir$
      PRINT #1, "@Light Yellow"
      PRINT #1, ""
      PRINT #1, "          ";
      PRINT #1, subname$(zk, 1) + " Subsector"
      tmpcount = 0
      DO UNTIL EOF(2)
         LINE INPUT #2, t$
         lstart = LEN(t$)
         IF lstart = 1 THEN t$ = ""
         IF lstart > 1 THEN t$ = RIGHT$(t$, lstart - 1)
         PRINT #1, t$;
         IF RIGHT$(t$, 1) = "@" THEN
            tmpcount = tmpcount + 1
            IF tmpcount = 1 THEN PRINT #1, f1$ + ".txt"
            IF tmpcount = 2 THEN PRINT #1, f1$ + "2.txt"
         ELSE
            PRINT #1, ""
         END IF: REM @
      LOOP
      CLOSE 1
      CLOSE 2
   END IF: REM exist=0
   REM go into subsector menu file
   SCREEN 0
   GOSUB 5500: REM egacolor
   SHELL "xtra\eg " + txtsub$ + " " + app$
END IF
394 SCREEN 12
GOTO 290

400 REM insert abv$ into sector file
f$ = secfp$
SHELL "copy " + f$ + " sector.tmp"
OPEN "i", 1, "sector.tmp"
OPEN "o", 2, f$
FOR i = 1 TO 7
   LINE INPUT #1, t$
   PRINT #2, t$
NEXT i
FOR i = 1 TO 16
   LINE INPUT #1, t$
   l = LEN(t$)
   IF i = zk THEN
      IF l < 49 THEN t$ = t$ + STRING$(49 - l, " ") + abv$
      IF l >= 49 THEN t$ = LEFT$(t$, 49) + abv$
   END IF
   PRINT #2, t$
NEXT i
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   PRINT #2, t$
LOOP
CLOSE 1
CLOSE 2
SHELL "erase sector.tmp"
RETURN

425 REM hexworld
IF world$(ref) = "" OR noname = 1 GOTO 200
IF hidden > 0 OR nonworld = 1 GOTO 200
tmp$ = hexdir$ + "p" + MID$(world$(ref), 15, 4)
tmp2$ = RTRIM$(LEFT$(world$(ref), 14))
IF hw$ <> "x" AND hw$ <> "z" THEN
   REM fix subsector file
   IF hw$ = "y" THEN newhw$ = "z" ELSE newhw$ = "x"
   CLS : COLOR 11: LOCATE 5
   PRINT "Creating a blank world..."
   SHELL "copy " + fsub$ + " data\tmpsub.dat"
   OPEN "i", 1, "data\tmpsub.dat"
   OPEN "o", 2, fsub$
   DO UNTIL EOF(1)
      LINE INPUT #1, tsub$
      IF world$(ref) = tsub$ THEN
         lline = LEN(tsub$)
         IF lline < 63 THEN
            tsub$ = tsub$ + SPACE$(63 - lline) + newhw$ + hidden$
         ELSE
            tsub$ = LEFT$(tsub$, 63) + newhw$ + hidden$
         END IF
      END IF
      PRINT #2, tsub$
   LOOP
   CLOSE 1
   CLOSE 2
   SHELL "erase data\tmpsub.dat"
END IF
SCREEN 0
SHELL "sub\hexworld " + tmp$ + " " + tmp2$
SCREEN 12: hhex = hex: trip = 1
GOTO 100

430 REM sysmap
IF world$(ref) = "" OR noname = 1 GOTO 200
IF hidden > 0 OR nonworld = 1 GOTO 200
tmp$ = sysdir$ + "s" + MID$(world$(ref), 15, 4)
tmp2$ = RTRIM$(LEFT$(world$(ref), 14))
IF hw$ <> "y" AND hw$ <> "z" THEN
   REM fix subsector file
   IF hw$ = "x" THEN newhw$ = "z" ELSE newhw$ = "y"
   CLS : COLOR 11: LOCATE 5
   PRINT "Creating a star system..."
   SHELL "copy " + fsub$ + " data\tmpsub.dat"
   OPEN "i", 1, "data\tmpsub.dat"
   OPEN "o", 2, fsub$
   DO UNTIL EOF(1)
      LINE INPUT #1, tsub$
      IF world$(ref) = tsub$ THEN
         lline = LEN(tsub$)
         IF lline < 63 THEN
            tsub$ = tsub$ + SPACE$(63 - lline) + newhw$ + hidden$
         ELSE
            tsub$ = LEFT$(tsub$, 63) + newhw$ + hidden$
         END IF
      END IF
      PRINT #2, tsub$
   LOOP
   CLOSE 1
   CLOSE 2
   SHELL "erase data\tmpsub.dat"
END IF
SCREEN 0
SHELL "sub\sysmap " + tmp$ + " " + tmp2$
SCREEN 12: hhex = hex: trip = 1
GOTO 100

440 REM delete world (or non-world)
IF LEN(world$(ref)) = 0 THEN GOTO 290
GOSUB 5620: REM insert star query
442 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 89 GOTO 445: REM y
IF k2 = 0 AND k1 = 78 GOTO 290: REM n
IF k2 = 0 AND k1 = 27 GOTO 290: REM esc
IF k2 = 0 AND k1 = 81 GOTO 290: REM q
GOTO 442
445 REM call insdel to delete star
SCREEN 0
SHELL "sub\insdel (del) " + hh$ + " " + fsub$
SCREEN 12: hhex = hex: trip = 1
GOTO 100

460 REM insert jump route
IF newjump$ <> "" GOTO 465
newjump$ = MID$(world$(ref), 15, 4)
newjx = zj: newjy = zi: newjf$ = fsub$
GOTO 290
465 REM 1st world already selected
IF newjump$ <> MID$(world$(ref), 15, 4) GOTO 470
newjump$ = ""
GOTO 290
470 REM 1st & 2nd world different
IF ABS(zj - newjx) > 1 OR ABS(zi - newjy) > 1 GOTO 478
GOSUB 5650: REM get color
472 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 >= 65 AND k1 <= 79 GOTO 475: REM a-o
IF k2 = 0 AND k1 = 27 OR k1 = 81 GOTO 478: REM esc/q
GOTO 472
475 tmp1$ = LTRIM$(STR$(k1 - 64))
REM from 1st to 2nd
tmp2$ = "$" + newjump$ + " " + MID$(world$(ref), 15, 4)
tmp2$ = tmp2$ + " " + LTRIM$(STR$(zj - newjx))
tmp2$ = tmp2$ + " " + LTRIM$(STR$(zi - newjy))
tmp2$ = tmp2$ + " " + tmp1$
REM from 2nd to 1st
tmp3$ = "$" + MID$(world$(ref), 15, 4) + " " + newjump$
tmp3$ = tmp3$ + " " + LTRIM$(STR$(newjx - zj))
tmp3$ = tmp3$ + " " + LTRIM$(STR$(newjy - zi))
tmp3$ = tmp3$ + " " + tmp1$
tmpfile$ = newjf$: tmp4$ = tmp2$: GOSUB 480
IF ABS(zj - newjx) = 1 OR ABS(zi - newjy) = 1 THEN
   tmpfile$ = fsub$: tmp4$ = tmp3$: GOSUB 480
END IF
478 newjump$ = "": hhex = hex: trip = 1: GOTO 100
480 SHELL "copy " + tmpfile$ + " data\tmpsub.dat"
OPEN "i", 1, "data\tmpsub.dat"
OPEN "o", 2, tmpfile$
DO UNTIL EOF(1)
LINE INPUT #1, tmp$
IF LEFT$(tmp$, 10) = "#--------1" THEN PRINT #2, tmp4$
PRINT #2, tmp$
LOOP
CLOSE 1
CLOSE 2
SHELL "erase data\tmpsub.dat"
RETURN

500 REM plot a hex
GOSUB 600
REM known=> cent1, cent2
REM from one o'clock clockwise
tmp1 = cent1 + .5 * chexa + yank
tmp2 = cent2 - hexb
tmp3 = cent1 + chexa + yank
tmp4 = cent2
LINE (tmp1, tmp2)-(tmp3, tmp4)
LINE -STEP(-.5 * chexa, chexb)
LINE -STEP(-chexa, 0)
LINE -STEP(-.5 * chexa, -chexb)
LINE -STEP(.5 * chexa, -chexb)
LINE -STEP(chexa, 0)
RETURN

600 REM find center point of hex
REM in=> hex
REM out=> cent1, cent2
cent1 = hexa
cent2 = hexb
thex = hex - 101
610 IF thex < 99 GOTO 620
REM going across
cent1 = cent1 + 1.5 * hexa
thex = thex - 100
GOTO 610
620 IF thex = 0 GOTO 630
REM going down
cent2 = cent2 + 2 * hexb
thex = thex - 1
GOTO 620
630 REM correct for even columns
IF INT(hex / 100) MOD 2 = 1 THEN GOTO 640
cent2 = cent2 + hexb
640 REM correct for screen aspect ratio
cent1 = cent1 * scar
RETURN

700 REM plot starport
IF LEN(world$(ref)) = 0 THEN RETURN
tmp3$ = MID$(world$(ref), 65, 1)
tmp4 = 0: tmp5 = 0: noname = 0
IF tmp3$ = "h" THEN tmp4 = 1
IF tmp3$ = "H" THEN tmp4 = 2
IF RTRIM$(LEFT$(world$(ref), 14)) = "." THEN noname = 1
nonworld = 0
IF MID$(world$(ref), 20, 1) = "*" THEN
   tmp5 = VAL(MID$(world$(ref), 21, 1))
   nonworld = 1
END IF
GOSUB 600: REM centerpoint
REM find allegiance
s$ = MID$(world$(ref), 56, 2)
FOR i2 = 1 TO basalgn(2)
   IF s$ = basalg$(2, i2, 1) THEN all = algncol(i2)
NEXT i2
REM draw marker
REM asteroids or circle
IF tmp5 = 0 THEN
   s$ = MID$(world$(ref), 21, 1)
   IF (s$ = "R" OR s$ = "0") AND tmp4 = 0 THEN
      x = cent1 + yank: y = cent2
      COLOR all
      PSET (x, y): PSET (x + 2, y + 2): PSET (x - 2, y - 2)
      PSET (x + 2, y - 2): PSET (x - 2, y + 2)
   ELSE
      PSET (cent1 + yank, cent2), 0
      CIRCLE (cent1 + yank, cent2), 3, all
      REM fill circle if there's any water
      IF MID$(world$(ref), 23, 1) <> "0" OR tmp4 <> 0 THEN
         PAINT (cent1 + yank, cent2), all
      END IF
   END IF
   REM gas giant & bases marker
   IF tmp4 = 0 THEN
      IF MID$(world$(ref), 54, 1) <> "0" THEN
         CIRCLE (cent1 + yank + 8, cent2 - 4), 1, all
         PSET (cent1 + yank + 8, cent2 - 4), all
      END IF
      IF MID$(world$(ref), 31, 1) <> " " THEN
         CIRCLE (cent1 + yank - 8, cent2 - 4), 1, all
         PSET (cent1 + yank - 8, cent2 - 4), all
      END IF
   END IF
END IF
REM nonworld markers
REM triangle
IF tmp5 = 1 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   PSET (x, y), 0
   LINE (x, y - 2)-(x + 2, y + 2), all
   LINE -STEP(-4, 0), all
   LINE -STEP(2, -4), all
   PAINT (x, y), all
END IF
REM square
IF tmp5 = 2 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   PSET (x, y), 0
   LINE (x - 2, y - 2)-(x + 2, y + 2), all, B
   PAINT (x, y), all
END IF
REM diamond
IF tmp5 = 3 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   PSET (x, y), 0
   LINE (x, y - 2)-(x + 2, y), all
   LINE -STEP(-2, 2), all
   LINE -STEP(-2, -2), all
   LINE -STEP(2, -2), all
   PAINT (x, y), all
END IF
REM lotsadots
IF tmp5 = 4 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   COLOR all
   FOR x2 = -16 TO 16 STEP 4
      FOR y2 = -16 TO 16 STEP 4
         IF ABS(x2 * y2) < 192 THEN PSET (x + x2, y + y2)
      NEXT y2
   NEXT x2
END IF
REM zone
IF tmp4 < 2 OR tmp5 = 0 THEN
   s$ = MID$(world$(ref), 49, 1)
   IF s$ = "A" THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 1, 14
   END IF
   IF s$ = "R" THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 1, 12
   END IF
   IF s$ = "B" THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 1, 11
   END IF
END IF
REM newjump circle
IF newjump$ = MID$(world$(ref), 15, 4) AND newjf$ = fsub$ THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2), 5
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 4, 5
END IF
REM write name
word$ = RTRIM$(LEFT$(world$(ref), 14))
IF uwptog = 1 THEN word$ = MID$(world$(ref), 20, 9)
lenword = LEN(word$)
x = cent1 + yank - (lenword * 3) + 1
y = cent2 + 10
IF tmp4 < 2 AND noname = 0 THEN GOSUB 5100
REM write starport
word$ = MID$(world$(ref), 20, 1)
x = cent1 + yank - 2: y = cent2 - 5
IF tmp4 = 0 AND word$ <> "*" THEN GOSUB 5100
RETURN

800 REM make circle
GOSUB 600
CIRCLE (cent1 + yank, cent2), hexa / 2, 13
RETURN

850 REM erase circle
GOSUB 600
CIRCLE (cent1 + yank, cent2), hexa / 2, 0
GOSUB 700
RETURN

900 REM get character from keyboard
k1 = 0: k2 = 0
910 k$ = INKEY$
IF k$ = "" THEN GOTO 910
k1 = ASC(k$)
IF k1 <> 0 THEN RETURN
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
RETURN

950 REM y/n
yn$ = ""
GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 78 THEN yn$ = "n": REM N
IF k2 = 0 AND k1 = 89 THEN yn$ = "y": REM Y
IF yn$ = "" GOTO 950
RETURN

1000 REM up
GOSUB 850
hex = hex - 1
IF RIGHT$(STR$(hex), 1) = "0" THEN GOTO 1002
GOSUB 800
GOTO 210
1002 IF zi <> 1 GOTO 1004
IF north$ <> "<nil>" THEN
   zi = 4: hhex = hex + 10
   newjy = newjy + 4: ynow = ynow - 1
   GOSUB 5710: GOSUB 2200
   trip = 1: GOTO 90
END IF
hex = hex + 1
GOSUB 800
GOTO 210
1004 zi = zi - 1
hhex = hex + 10
trip = 1
GOTO 90

1010 REM pgup/pgdn
GOSUB 850
IF k1 = 73 THEN hex = hex - ((hex - 1) MOD 10)
IF k1 = 81 THEN hex = hex + (9 - (hex - 1) MOD 10)
tmp1 = INT(hex / 100)
IF k1 = 15 THEN hex = (hex MOD 100) + (tmp1 - ((tmp1 - 1) MOD 8)) * 100
IF k1 = 9 THEN hex = (hex MOD 100) + (tmp1 + (7 - (tmp1 - 1) MOD 8)) * 100
GOSUB 800
GOTO 210

1020 REM down
GOSUB 850
hex = hex + 1
IF RIGHT$(STR$(hex), 1) = "1" THEN GOTO 1022
GOSUB 800
GOTO 210
1022 IF zi <> 4 THEN GOTO 1024
IF south$ <> "<nil>" THEN
   zi = 1: hhex = hex - 10
   newjy = newjy - 4: ynow = ynow + 1
   GOSUB 5710: GOSUB 2200
   trip = 1: GOTO 90
END IF
hex = hex - 1
GOSUB 800
GOTO 210
1024 zi = zi + 1
hhex = hex - 10
trip = 1
GOTO 90

1040 REM left
GOSUB 850
hex = hex - 100
IF hex < 100 THEN GOTO 1042
GOSUB 800
GOTO 210
1042 IF zj <> 1 THEN GOTO 1044
IF west$ <> "<nil>" THEN
   zj = 4: hhex = hex + 800
   newjx = newjx + 4: xnow = xnow - 1
   GOSUB 5710: GOSUB 2200
   trip = 1: GOTO 90
END IF
hex = hex + 100
GOSUB 800
GOTO 210
1044 zj = zj - 1
hhex = hex + 800
trip = 1
GOTO 90

1060 REM right
GOSUB 850
hex = hex + 100
IF hex > 900 THEN GOTO 1062
GOSUB 800
GOTO 210
1062 IF zj <> 4 THEN GOTO 1064
IF east$ <> "<nil>" THEN
   zj = 1: hhex = hex - 800
   newjx = newjx - 4: xnow = xnow + 1
   GOSUB 5710: GOSUB 2200
   trip = 1: GOTO 90
END IF
hex = hex - 100
GOSUB 800
GOTO 210
1064 zj = zj + 1
hhex = hex - 800
trip = 1
GOTO 90

1100 REM convert real hex to map hex
REM in -> rhex
REM out -> hex
t1 = INT(rhex / 100)
t2 = rhex - t1 * 100
1105 IF t1 <= 8 THEN GOTO 1110
t1 = t1 - 8
GOTO 1105
1110 IF t2 <= 10 THEN GOTO 1115
t2 = t2 - 10
GOTO 1110
1115 hex = t1 * 100 + t2
RETURN

1150 REM convert map hex to ref#
REM in -> hex
REM out -> ref
t1 = INT(hex / 100)
t2 = hex - t1 * 100
ref = (t1 - 1) * 10 + t2
RETURN

1175 REM convert ref# to map hex
REM in -> ref
REM out -> hex
t1 = INT((ref + 9) / 10)
t2 = ref MOD 10
IF t2 = 0 THEN t2 = 10
hex = t1 * 100 + t2
RETURN

1180 REM clear text half
LOCATE 1, 1
FOR t5 = 1 TO 28
PRINT SPACE$(35)
NEXT t5
REM draw little sector box
lsb1 = 10
lsb2 = 50
lsb3 = 260
lsb4 = 300
FOR i = lsb1 TO lsb2 STEP (lsb2 - lsb1) / 4
LINE (lsb3, i)-(lsb4, i), 1
NEXT i
FOR i = lsb3 TO lsb4 STEP (lsb4 - lsb3) / 4
LINE (i, lsb1)-(i, lsb2), 1
NEXT i
lsb5 = lsb1 + ((zi - 1) * ((lsb2 - lsb1) / 4))
lsb6 = lsb5 + ((lsb2 - lsb1) / 4)
lsb7 = lsb3 + ((zj - 1) * ((lsb4 - lsb3) / 4))
lsb8 = lsb7 + ((lsb4 - lsb3) / 4)
LINE (lsb7, lsb5)-(lsb8, lsb6), 12
LINE (lsb7, lsb6)-(lsb8, lsb5), 12
LOCATE 1, 1
RETURN

1200 REM empty hex
GOSUB 1180
PRINT "Empty Parsec"
REM PRINT "Subsector: "; subname$(zk, 1)
REM PRINT "Sector: "; secname$
tmphex = hex: GOSUB 1175
h$ = FNxstr$(hex)
h$ = "0" + h$
h1 = VAL(LEFT$(h$, 2))
h2 = VAL(RIGHT$(h$, 2))
h1 = h1 + (zj - 1) * 8
h2 = h2 + (zi - 1) * 10
sublet$ = CHR$(zk + 64)
h$ = sublet$ + h$
hh$ = FNxstr$(h1 * 100 + h2)
IF LEN(hh$) = 3 THEN hh$ = "0" + hh$
PRINT "Coordinates: "; hh$; " ("; h$; ")"
coord$ = hh$
hex = tmphex
GOTO 1255

1250 REM non-empty hex
GOSUB 1180
IF noname = 0 THEN
   IF hidden < 2 THEN
      IF nonworld = 0 THEN PRINT "World: ";
      PRINT RTRIM$(LEFT$(world$(ref), 14))
   ELSE
      IF nonworld = 0 THEN PRINT "World: ";
      PRINT "Unknown"
   END IF
END IF
REM PRINT "Subsector: "; subname$(zk, 1)
REM PRINT "Sector: "; secname$
hh$ = MID$(world$(ref), 15, 4)
coord$ = hh$
PRINT "Coordinates: "; hh$;
sublet$ = CHR$(zk + 64)
PRINT " (" + sublet$ + "0" + RIGHT$(STR$(hex), 3) + ")"

IF hidden > 0 THEN
   PRINT
   COLOR 11
   IF nonworld = 0 THEN PRINT "World Statistics Unknown"
END IF

IF hidden > 0 THEN GOTO 1255

IF nonworld = 1 THEN
   tmp$ = RTRIM$(MID$(world$(ref), 23, 25))
   IF tmp$ <> "" THEN
      PRINT : PRINT tmp$
   END IF
END IF
IF nonworld = 1 THEN GOTO 1255

PRINT "UWP: "; MID$(world$(ref), 20, 9);
extra$ = LTRIM$(RTRIM$(MID$(world$(ref), 58, 5)))
IF extra$ <> "" THEN
PRINT "-"; extra$
ELSE
PRINT
END IF

PRINT
FOR tmp = 1 TO numstats
   uwptmp$ = FNuwp$(tmp)
   IF uwptmp$ <> "Empty" THEN
      IF uwppos%(tmp, 3) = 0 THEN
         COLOR 11
      ELSE
         COLOR uwppos%(tmp, 3)
      END IF
      PRINT uwpstat$(tmp); ": "; uwptmp$
   END IF
NEXT tmp
PRINT : COLOR 10
GOSUB 1620: PRINT basalg$(2, 0, 0); " "; s1$
GOSUB 1590: PRINT basalg$(1, 0, 0); " "; s1$
GOSUB 1595: PRINT "Trade Codes: "; s1$
GOSUB 1610: PRINT "Travel Zone: "; s1$
1255 tmp$ = MID$(world$(ref), 63, 1)
PRINT
IF (tmp$ = "f" OR tmp$ = "m") AND noname = 0 THEN
   COLOR 13
   IF nonworld = 0 THEN PRINT "<Enter> = World Description"
   IF nonworld = 1 THEN PRINT "<Enter> = Site Description"
END IF
IF subtxt%(zk) <> 0 THEN
   COLOR 13: PRINT "F1 = Subsector Description"
END IF
IF (hw$ = "x" OR hw$ = "z") AND hidden = 0 THEN
   COLOR 13: PRINT "F4 = World Map"
END IF
IF (hw$ = "y" OR hw$ = "z") AND hidden = 0 THEN
   COLOR 13: PRINT "F8 = Star System Map"
END IF
COLOR 13: PRINT "? = Help";
RETURN

1590 REM bases
s$ = MID$(world$(ref), 31, 1)
FOR m = 1 TO basalgn(1)
IF s$ = basalg$(1, m, 1) THEN s1$ = basalg$(1, m, 2)
NEXT m
RETURN

1595 REM trade codes
IF MID$(world$(ref), 33, 1) = " " THEN
   s1$ = "None"
ELSE
   s1$ = MID$(world$(ref), 33, 16)
END IF
RETURN

1600 REM convert letter to number
REM in -> s$
REM out -> s
IF ASC(s$) >= 48 AND ASC(s$) <= 57 THEN s = VAL(s$)
IF ASC(s$) >= 65 AND ASC(s$) <= 90 THEN s = ASC(s$) - 55
RETURN

1610 REM zone
s$ = MID$(world$(ref), 49, 1)
IF s$ = " " OR s$ = "G" THEN s1$ = "Green"
IF s$ = "A" THEN s1$ = "Amber"
IF s$ = "R" THEN s1$ = "Red"
IF s$ = "B" THEN s1$ = "Blue"
RETURN

1620 REM allegiance
s$ = MID$(world$(ref), 56, 2)
FOR m = 1 TO basalgn(2)
IF s$ = basalg$(2, m, 1) THEN s1$ = basalg$(2, m, 2)
NEXT m
RETURN

2000 REM more information
IF world$(ref) = "" OR hidden > 0 OR noname = 1 THEN GOTO 200
ss$ = MID$(world$(ref), 63, 1)
app$ = reader$
IF k1 = 62 THEN app$ = editor$
IF ss$ <> "f" AND ss$ <> "m" THEN
 tmp$ = "star system"
 GOSUB 5600: REM mini-menu
2010 GOSUB 900
 IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
 IF k2 = 0 AND k1 = 70 GOTO 2020: REM f
 IF k2 = 0 AND k1 = 77 GOTO 2020: REM m
 IF k2 = 0 AND k1 = 27 GOTO 2040: REM esc
 IF k2 = 0 AND k1 = 81 GOTO 2040: REM q
 GOTO 2010
2020 REM attach file/menu
 IF k1 = 70 THEN ss$ = "f"
 IF k1 = 77 THEN ss$ = "m"
 REM fix subsector file
 SHELL "copy " + fsub$ + " data\tmpsub.dat"
 OPEN "i", 1, "data\tmpsub.dat"
 OPEN "o", 2, fsub$
 DO UNTIL EOF(1)
  LINE INPUT #1, tsub$
  IF world$(ref) = tsub$ THEN
   lline = LEN(tsub$)
   IF lline < 62 THEN
    tsub$ = tsub$ + SPACE$(62 - lline) + ss$ + hw$ + hidden$
   ELSE
    tsub$ = LEFT$(tsub$, 62) + ss$ + hw$ + hidden$
   END IF
  END IF
  PRINT #2, tsub$
 LOOP
 CLOSE 1
 CLOSE 2
 SHELL "erase data\tmpsub.dat"
 app$ = editor$: trip2 = 1
 IF ss$ = "m" THEN
  f$ = locdir$ + "p" + MID$(world$(ref), 15, 4) + ".mnu"
  f1$ = "p" + MID$(world$(ref), 15, 4)
  REM check if file f$ exists
  OPEN "r", 1, f$
  exist = LOF(1)
  CLOSE 1
  IF exist = 0 THEN
   SHELL "erase " + f$
   OPEN "o", 1, f$
   OPEN "i", 2, "data\starter.mnu"
   PRINT #1, "@dir=" + locdir$
   PRINT #1, "@Light Yellow"
   PRINT #1, ""
   PRINT #1, "          ";
   PRINT #1, RTRIM$(LEFT$(world$(ref), 14)) + " " + "System"
   tmpcount = 0
   DO UNTIL EOF(2)
    LINE INPUT #2, t$
    lstart = LEN(t$)
    IF lstart = 1 THEN t$ = ""
    IF lstart > 1 THEN t$ = RIGHT$(t$, lstart - 1)
    PRINT #1, t$;
    IF RIGHT$(t$, 1) = "@" THEN
     tmpcount = tmpcount + 1
     IF tmpcount = 1 THEN PRINT #1, f1$ + ".txt"
     IF tmpcount = 2 THEN PRINT #1, f1$ + "b.txt"
     ELSE
     PRINT #1, ""
    END IF: REM @
   LOOP
   CLOSE 1
   CLOSE 2
  END IF: REM exist=0
 END IF: REM ss$="m"
 REM write system stats to text file if file doesn't already exist
 REM check if file f$ exists
 f$ = locdir$ + "p" + MID$(world$(ref), 15, 4) + ".txt"
 OPEN "r", 1, f$
 exist = LOF(1)
 CLOSE 1
 IF exist = 0 THEN
  SHELL "erase " + f$
  OPEN "o", 1, f$
  IF nonworld = 0 THEN PRINT #1, "World: ";
  PRINT #1, RTRIM$(LEFT$(world$(ref), 14))
  PRINT #1, "Subsector: "; subname$(zk, 1)
  PRINT #1, "Sector: "; secname$
  PRINT #1, "Coordinates: "; MID$(world$(ref), 15, 4);
  PRINT #1, " (" + CHR$(zk + 64) + "0" + RIGHT$(STR$(hex), 3) + ")"
  IF nonworld = 0 THEN
     PRINT #1, "UWP: "; MID$(world$(ref), 20, 9);
     extra$ = LTRIM$(RTRIM$(MID$(world$(ref), 58, 5)))
     IF extra$ <> "" THEN
        PRINT #1, "-"; extra$
     ELSE
        PRINT #1, ""
     END IF
  END IF
  PRINT #1, ""
  IF nonworld = 1 THEN
     tmp$ = RTRIM$(MID$(world$(ref), 23, 25))
     IF tmp$ <> "" THEN PRINT #1, tmp$
  ELSE
     FOR tmp = 1 TO numstats
      uwptmp$ = FNuwp$(tmp)
      IF uwptmp$ <> "Empty" THEN
       PRINT #1, uwpstat$(tmp); ": "; uwptmp$
      END IF
     NEXT tmp
     PRINT #1, ""
     GOSUB 1620: PRINT #1, basalg$(2, 0, 0); " "; s1$
     GOSUB 1590: PRINT #1, basalg$(1, 0, 0); " "; s1$
     GOSUB 1595: PRINT #1, "Trade Codes: "; s1$
     GOSUB 1610: PRINT #1, "Travel Zone: "; s1$
  END IF
  CLOSE 1
 END IF: REM exist=0
END IF: REM ss$ <> ...
REM *** end if block ***
SCREEN 0
f$ = locdir$ + "p" + MID$(world$(ref), 15, 4)
IF ss$ = "f" THEN f$ = f$ + ".txt"
IF ss$ = "m" THEN f$ = f$ + ".mnu"
GOSUB 5500: REM egacolor
IF ss$ = "f" THEN SHELL app$ + " " + f$
IF ss$ = "m" THEN SHELL "xtra\eg " + f$ + " " + app$
SCREEN 12
2040 hhex = hex: trip = 1
IF trip2 = 1 THEN
   trip2 = 0
   GOTO 100
END IF
GOTO 150

2200 REM get sector data
GOSUB 5450: REM read galaxy's uwp stats
f$ = secfp$
OPEN "i", 1, f$
LINE INPUT #1, secname$
LINE INPUT #1, temp$
GOSUB 3700: REM determine n/s/e/w
FOR i = 1 TO 16
 LINE INPUT #1, temp$
 t9 = LEN(temp$)
 subtxt%(i) = 0
 IF MID$(temp$, 50, 1) = "f" THEN subtxt%(i) = 1
 IF MID$(temp$, 50, 1) = "m" THEN subtxt%(i) = 2
 subname$(i, 1) = RTRIM$(MID$(temp$, 4, 26))
 subname$(i, 2) = RTRIM$(MID$(temp$, 30, 12))
NEXT i
j = 1
LINE INPUT #1, temp$
2244 REM get base & status info
i = 0
LINE INPUT #1, basalg$(j, i, 0)
i = 1
2245 IF EOF(1) = -1 THEN GOTO 2246
LINE INPUT #1, temp$
IF temp$ = "" THEN GOTO 2246
t9 = LEN(temp$)
IF j = 1 THEN
   basalg$(1, i, 1) = LEFT$(temp$, 1)
   basalg$(1, i, 2) = RTRIM$(RIGHT$(temp$, t9 - 4))
END IF
IF j = 2 THEN
   algncol(i) = VAL(LEFT$(temp$, 2))
   basalg$(2, i, 1) = MID$(temp$, 4, 2)
   basalg$(2, i, 2) = RTRIM$(RIGHT$(temp$, t9 - 8))
END IF
i = i + 1
GOTO 2245
2246 basalgn(j) = i - 1
IF j = 2 GOTO 2248
j = j + 1
GOTO 2244
2248 CLOSE 1
RETURN

3000 REM get local map data

3100 REM draw map
SCREEN 12: CLS
FOR a = xnow - 3 TO xnow + 3
FOR b = ynow - 3 TO ynow + 3
   loc1 = (a - xnow + 4) * 11 - 10
   loc2 = (b - ynow + 4) * 4 - 3
   hit = FNsec(a, b)
   LOCATE loc2, loc1: COLOR 9
   PRINT CHR$(197); STRING$(10, 196); CHR$(197);
   IF hit = 0 THEN
      FOR d = 1 TO 3
         LOCATE loc2 + d, loc1: COLOR 9
         PRINT CHR$(179); STRING$(10, 32); CHR$(179);
      NEXT d
   ELSE
      FOR c = 1 TO 3
         pr$(c) = ""
      NEXT c
      c = 1: d = 0
      FOR e = 1 TO LEN(sec$(hit, 2))
         IF MID$(sec$(hit, 2), e, 1) = " " THEN
            c = c + 1: d = 0
         ELSE
            d = d + 1
            IF c <= 3 AND d <= 10 THEN
               pr$(c) = pr$(c) + MID$(sec$(hit, 2), e, 1)
            END IF
         END IF
      NEXT e
      FOR e = 1 TO 3
         pr$(e) = SPACE$(INT(10 - LEN(pr$(e))) / 2 - .1) + pr$(e)
         pr$(e) = pr$(e) + SPACE$(10 - LEN(pr$(e)))
      NEXT e
      IF LTRIM$(pr$(2)) = "" THEN SWAP pr$(1), pr$(2)
      FOR d = 1 TO 3
         LOCATE loc2 + d, loc1
         COLOR 9: PRINT CHR$(179);
         COLOR col(hit): PRINT pr$(d);
         COLOR 9: PRINT CHR$(179);
      NEXT d
   END IF
NEXT b
NEXT a
FOR d = 1 TO 7
   LOCATE 29, d * 11 - 10: COLOR 9
   PRINT CHR$(197); STRING$(10, 196); CHR$(197);
NEXT d
LOCATE 13, 34: COLOR 11
PRINT CHR$(201); STRING$(10, 205); CHR$(187);
FOR d = 14 TO 16
   LOCATE d, 34: PRINT CHR$(186); : LOCATE d, 45: PRINT CHR$(186)
NEXT d
LOCATE 17, 34: PRINT CHR$(200); STRING$(10, 205); CHR$(188);

IF movesec <> 0 THEN
   IF ABS(mvsecx - xnow) < 4 AND ABS(mvsecy - ynow) < 4 THEN
      loc1 = (mvsecx - xnow + 4) * 11 - 10
      loc2 = (mvsecy - ynow + 4) * 4 - 3
      COLOR 13
      LOCATE loc2, loc1
      PRINT CHR$(218); STRING$(10, 196); CHR$(191);
      FOR d = 1 TO 3
         FOR d2 = 0 TO 11 STEP 11
            LOCATE loc2 + d, loc1 + d2
            PRINT CHR$(179);
         NEXT d2
      NEXT d
      LOCATE loc2 + 4, loc1
      PRINT CHR$(192); STRING$(10, 196); CHR$(217);
   END IF
END IF

IF movesec <> 0 THEN
 LOCATE 29, 10: COLOR 13
 PRINT "To move sector: move to empty cell and hit <F6> again";
END IF
LOCATE 29, 70: COLOR 12: PRINT "?=Help";

secocc = FNsec(xnow, ynow)
IF secocc = 0 GOTO 3200
sec0$ = sec$(secocc, 1)
GOSUB 3800: REM assign dirs

3200 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 1 AND k1 = 72 GOTO 3300: REM up
IF k2 = 0 AND k1 = 75 GOTO 3300: REM k
IF k2 = 1 AND k1 = 80 GOTO 3310: REM down
IF k2 = 0 AND k1 = 74 GOTO 3310: REM j
IF k2 = 1 AND k1 = 75 GOTO 3320: REM left
IF k2 = 0 AND k1 = 72 GOTO 3320: REM h
IF k2 = 1 AND k1 = 77 GOTO 3330: REM right
IF k2 = 0 AND k1 = 76 GOTO 3330: REM l
IF k2 = 0 AND k1 = 27 GOTO 3500: REM esc
IF k2 = 0 AND k1 = 81 GOTO 3500: REM q
IF k2 = 0 AND k1 = 13 GOTO 3550: REM enter
IF k2 = 0 AND k1 = 32 GOTO 3550: REM space
IF k2 = 0 AND k1 = 78 GOTO 3480: REM n
IF k2 = 0 AND k1 = 73 GOTO 3400: REM i
IF k2 = 0 AND k1 = 88 GOTO 3420: REM x
IF k2 = 1 AND k1 = 83 GOTO 3440: REM delete
IF k2 = 1 AND k1 = 82 THEN 3460: REM insert (create)
IF k2 = 1 AND k1 = 64 GOTO 3350: REM F6
catch = 0: REM hook catching
FOR tmp = 1 TO nhook%(1)
   IF k2 = hooke%(1, tmp) AND k1 = hookac%(1, tmp) THEN catch = tmp
NEXT tmp
IF catch > 0 GOTO 3210
GOTO 3200

3210 REM hook caught
IF INSTR(hookspec$(1, catch), "1") > 0 AND secocc = 0 GOTO 3200
IF INSTR(hookspec$(1, catch), "0") > 0 AND secocc > 0 GOTO 3200
CLS : SCREEN 0
IF INSTR(hookspec$(1, catch), "E") > 0 THEN
   GOSUB 5500
END IF
GOSUB 5727: REM write current position
sec0$ = sec$(FNsec(xnow, ynow), 1)
GOSUB 3800: REM file/directory paths
SHELL FNhook$(hookcom$(1, catch))
GOSUB 5725: REM read new position
REM IF INSTR(hookspec$(1, catch), "U") > 0 THEN do nothing
IF INSTR(hookspec$(1, catch), "P") > 0 THEN GOSUB 3900
GOSUB 3600
GOTO 3000

3300 REM up
ynow = ynow - 1
GOTO 3100
3310 REM down
ynow = ynow + 1
GOTO 3100
3320 REM left
xnow = xnow - 1
GOTO 3100
3330 REM right
xnow = xnow + 1
GOTO 3100

3350 REM move sector
tmp = FNsec(xnow, ynow)
IF movesec <> 0 GOTO 3360
REM picking sector up
IF tmp = 0 GOTO 3100
movesec = tmp
mvsecx = xnow
mvsecy = ynow
GOTO 3100
3360 REM putting sector down
IF xnow = mvsecx AND ynow = mvsecy THEN movesec = 0
IF tmp <> 0 GOTO 3100
tmp = movesec
xx(tmp) = xnow
yy(tmp) = ynow
listfile$ = galdir$ + "\" + gal0$ + ".lst"
SHELL "copy " + listfile$ + " tmp.tmp"
OPEN "i", 1, "tmp.tmp"
OPEN "o", 2, listfile$
LINE INPUT #1, t$
PRINT #2, t$
LINE INPUT #1, t$
PRINT #2, t$
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 IF RTRIM$(LEFT$(t$, 8)) = sec$(tmp, 1) THEN
  t2$ = LEFT$(t$, 50)
  nowatx$ = FNxstr$(xnow)
  t2$ = t2$ + nowatx$ + SPACE$(5 - LEN(nowatx$))
  nowaty$ = FNxstr$(ynow)
  t2$ = t2$ + nowaty$ + SPACE$(5 - LEN(nowaty$))
  t2$ = t2$ + MID$(t$, 61, 1)
  PRINT #2, t2$
 ELSE
  PRINT #2, t$
 END IF
LOOP
movesec = 0
CLOSE
SHELL "del tmp.tmp"
GOSUB 3600
GOTO 3100

3400 REM import from archive
CLS : COLOR 11
SHELL "xtra\ls *.sar > tmp.tmp"
OPEN "i", 1, "tmp.tmp"
l = LOF(1)
CLOSE 1
IF l = 0 THEN
   SHELL "del tmp.tmp"
   CLS
   PRINT "There are no .sar files available for importing"
   GOSUB 900
END IF
IF l = 0 GOTO 3000
CLS
PRINT "Files available for importing:": PRINT
SHELL "xtra\ls *.sar"
COLOR 10: PRINT
INPUT "Name of file to be imported: ", t$
t$ = LTRIM$(RTRIM$(LCASE$(t$)))
IF t$ = "" THEN SHELL "del tmp.tmp"
IF t$ = "" GOTO 3000
IF LEN(t$) < 4 THEN t$ = t$ + ".sar"
IF RIGHT$(t$, 4) <> ".sar" THEN t$ = t$ + ".sar"
ok = 0
OPEN "i", 1, "tmp.tmp"
DO UNTIL EOF(1)
 LINE INPUT #1, tmp$
 IF t$ = tmp$ THEN ok = 1
LOOP
CLOSE 1
SHELL "del tmp.tmp"
IF ok = 0 GOTO 3400
CLS : SCREEN 0
SHELL "sub\arch -d " + t$
GOSUB 3600: REM read list of sectors
GOTO 3000

3420 REM export to archive
GOSUB 5722: REM write gals\where.dat
sec0$ = sec$(FNsec(xnow, ynow), 1)
CLS : SCREEN 0
SHELL "sub\arch " + gal0$ + "\" + sec0$
GOTO 3000

3440 REM delete sector
CLS : LOCATE 5
gal0$ = gals$(curgal, 1)
galdir$ = "gals\" + gal0$
tmp = FNsec(xnow, ynow)
IF tmp = 0 GOTO 3000
sec0$ = sec$(tmp, 1)
secdir$ = galdir$ + "\" + sec0$
listfile$ = galdir$ + "\" + gal0$ + ".lst"
CLS : COLOR 11: LOCATE 5
IF col(tmp) = 8 THEN
   PRINT "Are you sure you want to remove ";
ELSE
   PRINT "Are you sure you want to delete ";
END IF
PRINT sec$(FNsec(xnow, ynow), 2);
IF col(tmp) = 8 THEN PRINT " entirely";
PRINT "? (y/n)"
GOSUB 950
IF yn$ = "n" GOTO 3000
CLS
IF col(tmp) <> 8 THEN SHELL "deltree " + secdir$
OPEN "i", 1, listfile$
OPEN "o", 2, "tmp.tmp"
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF RTRIM$(LEFT$(t$, 8)) <> sec0$ THEN
      PRINT #2, t$
   ELSE
      IF col(tmp) <> 8 THEN PRINT #2, LEFT$(t$, LEN(t$) - 1) + "I"
   END IF
LOOP
CLOSE 1
CLOSE 2
SHELL "del " + listfile$
SHELL "copy tmp.tmp " + listfile$
SHELL "del tmp.tmp"
GOSUB 3600: REM read list of sectors
GOTO 3000

3460 REM insert/create sector
tmp = FNsec(xnow, ynow)
IF tmp = 0 GOTO 3462
IF col(tmp) <> 8 GOTO 3000
sec0$ = sec$(tmp, 1)
GOTO 3464
3462 REM sector still unnamed
sec0$ = ""
3464 GOSUB 5722: REM write gals\where.dat
GOSUB 5727: REM write gals\<galaxy>\where.dat
SHELL "sub\makesec " + sec0$
OPEN "i", 1, "secgen.tmp"
LINE INPUT #1, t$
CLOSE 1
SHELL "del secgen.tmp"
IF t$ = "full steam ahead" THEN SHELL "sub\secgen 000"
GOSUB 3600: REM read list of sectors
GOTO 3000

3480 REM add sector name to map
tmp = FNsec(xnow, ynow)
IF tmp > 0 GOTO 3000
CLS : COLOR 11
3485 LOCATE 5: PRINT SPACE$(79): LOCATE 5: tmp2 = 0
INPUT "Sector Name (35 chars max): ", tmp2$
tmp2$ = LTRIM$(RTRIM$(tmp2$))
IF tmp2$ = "" GOTO 3000
IF LEN(tmp2$) > 35 THEN tmp2 = 1
FOR tmp1 = 1 TO numsec
   IF sec$(tmp1, 2) = tmp2$ THEN tmp2 = 2
NEXT tmp1
LOCATE 7: PRINT SPACE$(79): LOCATE 7
IF tmp2 = 1 THEN PRINT "(35 chararcters max)"
IF tmp2 = 2 THEN PRINT "(sector name already taken)"
IF tmp2 > 0 GOTO 3485
3490 LOCATE 10: PRINT SPACE$(79): LOCATE 10: tmp2 = 0
INPUT "Sector Directory (8 chars max): ", tmp1$
tmp1$ = LTRIM$(RTRIM$(LCASE$(tmp1$)))
IF tmp1$ = "" GOTO 3480
IF LEN(tmp1$) > 8 THEN tmp2 = 1
FOR tmp1 = 1 TO numsec
   IF sec$(tmp1, 1) = tmp1$ THEN tmp2 = 2
NEXT tmp1
IF INSTR(tmp1$, " ") > 0 THEN tmp2 = 3
LOCATE 12: PRINT SPACE$(79): LOCATE 12
IF tmp2 = 1 THEN PRINT "(8 characters max)"
IF tmp2 = 2 THEN PRINT "(directory name already taken)"
IF tmp2 = 3 THEN PRINT "(no spaces allowed)"
IF tmp2 > 0 GOTO 3490
secline$ = tmp1$ + SPACE$(13 - LEN(tmp1$))
secline$ = secline$ + tmp2$ + SPACE$(37 - LEN(tmp2$))
tmp3$ = FNxstr$(xnow)
tmp3$ = tmp3$ + SPACE$(4 - LEN(tmp3$))
tmp4$ = FNxstr$(ynow)
tmp4$ = tmp4$ + SPACE$(4 - LEN(tmp4$))
secline$ = secline$ + tmp3$ + " " + tmp4$ + " I"
OPEN "a", 1, seclist$
PRINT #1, secline$
CLOSE 1
GOSUB 3600: REM read list of sectors
GOTO 3000

3500 REM esc
GOSUB 5727: REM write gals\<sector>\where.dat
COLOR 7
PRINT "."
GOTO 5760: REM galaxy menu

3550 REM enter
tmp = FNsec(xnow, ynow)
IF tmp = 0 GOTO 3000
IF col(tmp) = 8 GOTO 3460
COLOR 7
PRINT "."
GOSUB 5710: REM shift of sector
GOTO 40

3600 REM read list of sectors
FOR a = 1 TO 200
xx(a) = 0: yy(a) = 0: col(a) = 0
sec$(a, 1) = ""
sec$(a, 2) = ""
NEXT a
a = 0
seclist$ = galdir$ + "\" + gal0$ + ".lst"
OPEN "i", 1, seclist$
INPUT #1, t$
INPUT #1, t$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   t$ = LTRIM$(RTRIM$(t$))
   IF t$ = "" GOTO 3610
   IF LEFT$(t$, 1) = "#" GOTO 3610
   a = a + 1
   xx(a) = VAL(MID$(t$, 51, 4))
   yy(a) = VAL(MID$(t$, 56, 4))
   col(a) = ASC(MID$(t$, 61, 1)) - 65
   sec$(a, 1) = RTRIM$(LEFT$(t$, 8))
   sec$(a, 2) = LTRIM$(RTRIM$(MID$(t$, 14, 37)))
3610 LOOP
CLOSE 1
numsec = a
RETURN

3700 REM determine n/s/e/w
north$ = "<nil>"
south$ = "<nil>"
east$ = "<nil>"
west$ = "<nil>"
FOR a = 1 TO numsec
 dude$ = sec$(a, 1)
 IF col(a) = 8 THEN dude$ = "<nil>"
 IF xx(a) = xnow + 1 AND yy(a) = ynow THEN east$ = dude$
 IF xx(a) = xnow - 1 AND yy(a) = ynow THEN west$ = dude$
 IF xx(a) = xnow AND yy(a) = ynow + 1 THEN south$ = dude$
 IF xx(a) = xnow AND yy(a) = ynow - 1 THEN north$ = dude$
NEXT a
RETURN

3800 REM determine directory/file paths
REM gal0$ & sec0$ are known
galdir$ = "gals\" + gal0$
seclist$ = galdir$ + "\" + gal0$ + ".lst"
secdir$ = galdir$ + "\" + sec0$
mapdir$ = secdir$ + "\" + "map\"
locdir$ = secdir$ + "\" + "loc\"
gendir$ = secdir$ + "\" + "gen\"
hexdir$ = secdir$ + "\" + "hex\"
sysdir$ = secdir$ + "\" + "sys\"
secfile$ = sec0$ + ".dat"
secfp$ = secdir$ + "\" + secfile$
RETURN

3900 REM reload positional info
GOSUB 5725: REM read gals\<sector>\where.dat
GOSUB 3600: REM read list of sectors
sec0$ = sec$(FNsec(xnow, ynow), 1)
GOSUB 3800: REM file/directory paths
RETURN

5000 REM get letter image data
SCREEN 12
GOSUB 5010
OPEN "i", 1, "data\letters.dat"
FOR z = 1 TO 44
INPUT #1, t$
FOR a = 1 TO 5
INPUT #1, lrow$(a)
NEXT a
REM cls
COLOR 15: GOSUB 5005
GET (1, 1)-(l, 5), letimage(1, z)
COLOR 0: GOSUB 5005
NEXT z
CLOSE
SCREEN 0
RETURN
5005 FOR a = 1 TO 5
length(z) = LEN(lrow$(a)) - 2
l = length(z)
FOR b = 1 TO l
IF MID$(lrow$(a), b + 1, 1) = "*" THEN PSET (b, a)
NEXT b
NEXT a
RETURN

5010 REM loading data message
CLS : COLOR 14: LOCATE 8, 3
PRINT "Loading Data..."
RETURN

5100 REM subroutine: print word
y = y - 4
l = LEN(word$)
IF l = 0 THEN RETURN
FOR a = -1 TO 5
   LINE (x - 1, y + a)-(x + l * 6 - 1, y + a), 0
NEXT a
xunder = x: yunder = y + 6
word$ = UCASE$(word$)
FOR a = 1 TO l
let$ = MID$(word$, a, 1)
REM convert let$ to letnum
SELECT CASE ASC(let$)
   CASE IS > 64
        letnum = ASC(let$) - 64
   CASE 48 TO 57
        letnum = ASC(let$) - 21
   CASE 32
        letnum = 39
   CASE 39
        letnum = 38
   CASE 43
        letnum = 40
   CASE 45
        letnum = 37
   CASE 46
        letnum = 42
   CASE 58
        letnum = 41
   CASE 33
        letnum = 43
   CASE 63
        letnum = 44
END SELECT
IF x <= 635 AND y <= 479 THEN
   PUT (x, y), letimage(1, letnum), PSET
END IF
x = x + length(letnum) + 1
NEXT a
REM underline if hi pop world
hipop = FNnumber(MID$(world$(ref), 24, 1))
IF hipop >= 9 AND l > 1 AND nonworld = 0 THEN
   LINE (xunder, yunder)-(x - 2, yunder), 15
END IF
RETURN

5200 REM calculate video stuff
xmost = 640
ymost = 500
REM screen aspect ratio
REM scar = 2.4
scar = (3 / 4) * (xmost / ymost)
REM hex radii
hexa = 25
hexb = INT((hexa ^ 2 - (.5 * hexa) ^ 2) ^ .5)
REM corrected for aspect ratio
chexa = hexa * scar
chexb = hexb
REM yank right
yank = xmost - INT(chexa * 1.5 * 8.3333) - 22
zi = 1
zj = 1
RETURN

5450 REM read in galaxy's uwp codes
OPEN "r", 1, galdir$ + "\uwp.dat"
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN
   SHELL "copy data\uwp.dat " + galdir$ + "\uwp.dat"
END IF
OPEN "i", 1, galdir$ + "\uwp.dat"
t$ = ""
a = 0: b = 0
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LTRIM$(t$) <> "" AND LEFT$(t$, 1) <> "#" THEN
      c = INSTR(t$, "=")
      IF c = 0 THEN
         IF a > 0 THEN uwpnum%(a) = b
         a = a + 1: b = 0
         uwpstat$(a) = t$
      END IF
      IF LEFT$(t$, 4) = "pos=" THEN
         uwppos%(a, 1) = VAL(MID$(t$, 5, 2))
         IF LEN(t$) > 6 THEN
            uwppos%(a, 2) = VAL(MID$(t$, 8, 2))
         ELSE
            uwppos%(a, 2) = 0
         END IF
         IF LEN(t$) > 9 THEN
            uwppos%(a, 3) = VAL(MID$(t$, 11, 2))
         ELSE
            uwppos%(a, 3) = 0
         END IF
      END IF
      IF c <> 0 AND LEFT$(t$, 4) <> "pos=" THEN
         b = b + 1
         tmp$ = RTRIM$(LTRIM$(LEFT$(t$, c - 1)))
         IF LEN(tmp$) < 3 THEN
            uwpval%(a, b, 1) = FNnumber(tmp$)
            uwpval%(a, b, 2) = uwpval%(a, b, 1)
         ELSE
            uwpval%(a, b, 1) = FNnumber(LEFT$(tmp$, 1))
            uwpval%(a, b, 2) = FNnumber(RIGHT$(tmp$, 1))
         END IF
         uwpdef$(a, b) = RTRIM$(LTRIM$(RIGHT$(t$, LEN(t$) - c)))
      END IF
   END IF
LOOP
uwpnum%(a) = b
numstats = a
CLOSE 1
5460 REM read in sector's uwp amendments
REM check if file exists
IF nosector = 1 THEN RETURN
OPEN "r", 1, secdir$ + "\uwp.dat"
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN SHELL "erase " + secdir$ + "\uwp.dat"
IF exist = 0 THEN RETURN
OPEN "i", 1, secdir$ + "\uwp.dat"
t$ = ""
first = 1
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LTRIM$(t$) <> "" AND LEFT$(t$, 1) <> "#" THEN
      c = INSTR(t$, "=")
      IF c = 0 THEN
         IF first = 0 THEN uwpnum%(a) = b
         IF first = 1 THEN first = 0
         a = 0
         FOR b1 = 1 TO numstats
            IF t$ = uwpstat$(b1) THEN a = b1
         NEXT b1
         IF a = 0 THEN
            CLS
            PRINT "Error: ";
            PRINT t$; " not defined in "; galdir$ + "\uwp.dat"
            END
         END IF
         b = uwpnum%(a)
      END IF
      IF c <> 0 THEN
         b = b + 1
         tmp$ = RTRIM$(LTRIM$(LEFT$(t$, c - 1)))
         IF LEN(tmp$) < 3 THEN
            uwpval%(a, b, 1) = FNnumber(tmp$)
            uwpval%(a, b, 2) = uwpval%(a, b, 1)
         ELSE
            uwpval%(a, b, 1) = FNnumber(LEFT$(tmp$, 1))
            uwpval%(a, b, 2) = FNnumber(RIGHT$(tmp$, 1))
         END IF
         uwpdef$(a, b) = RTRIM$(LTRIM$(RIGHT$(t$, LEN(t$) - c)))
      END IF
   END IF
LOOP
uwpnum%(a) = b
CLOSE 1
RETURN

5500 REM egacolor gold on blue
COLOR 7: CLS : PRINT "."
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
RETURN

5550 REM read 15 colors
OPEN "i", 1, "xtra\colors.dat"
LINE INPUT #1, tmp$
FOR a = 1 TO 15
   LINE INPUT #1, tmp$
   colors$(a) = RIGHT$(tmp$, LEN(tmp$) - 4)
NEXT a
CLOSE 1
RETURN

5600 REM mini-menu #1 (attach file/menu query)
COLOR 14
LOCATE 5, 20
PRINT CHR$(218); STRING$(38, 196); CHR$(191)
FOR tmp = 6 TO 14
LOCATE tmp, 20
PRINT CHR$(179); STRING$(38, 32); CHR$(179)
NEXT tmp
LOCATE 15, 20
PRINT CHR$(192); STRING$(38, 196); CHR$(217)
COLOR 11
LOCATE 7, 22
PRINT "There is no file or menu currently"
LOCATE 8, 22
PRINT "attached to this "; tmp$; ". Your"
LOCATE 9, 22
PRINT "options are:"
COLOR 10
LOCATE 11, 27
PRINT "(F) Attach a File"
LOCATE 12, 27
PRINT "(M) Attach a Menu"
LOCATE 13, 27
PRINT "(Q) Get Me Outta Here"
RETURN

5620 REM mini-menu #2 (delete star query)
COLOR 14
LOCATE 5, 17
PRINT CHR$(218); STRING$(44, 196); CHR$(191)
FOR tmp = 6 TO 12
LOCATE tmp, 17
PRINT CHR$(179); STRING$(44, 32); CHR$(179)
NEXT tmp
LOCATE 13, 17
PRINT CHR$(192); STRING$(44, 196); CHR$(217)
COLOR 11
LOCATE 7, 21
PRINT "Are you sure you really want to delete"
LOCATE 8, 21
PRINT "this place?"
COLOR 10
LOCATE 10, 19
PRINT "(Y) Ya dang right I do! I hate those guys!"
LOCATE 11, 19
PRINT "(N) Nah, we'll have pity on the poor sots."
RETURN

5640 REM mini-menu #3 (sector's uwp.dat query)
COLOR 14
LOCATE 5, 17
PRINT CHR$(218); STRING$(44, 196); CHR$(191)
FOR tmp = 6 TO 12
LOCATE tmp, 17
PRINT CHR$(179); STRING$(44, 32); CHR$(179)
NEXT tmp
LOCATE 13, 17
PRINT CHR$(192); STRING$(44, 196); CHR$(217)
COLOR 11
LOCATE 7, 21
PRINT "This sector has no uwp.dat file. Would"
LOCATE 8, 21
PRINT "you like me to copy the one from the"
LOCATE 9, 21
PRINT "classic\beyond directory?"
COLOR 10: LOCATE 11, 29
PRINT "(Y) Yep     (N) Nope"
RETURN

5650 REM mini-menu #4 (jumproute color query)
COLOR 14: LOCATE 3, 17
PRINT CHR$(218); STRING$(44, 196); CHR$(191)
FOR tmp = 4 TO 22
LOCATE tmp, 17
PRINT CHR$(179); STRING$(44, 32); CHR$(179)
NEXT tmp
LOCATE 23, 17
PRINT CHR$(192); STRING$(44, 196); CHR$(217)
COLOR 11: LOCATE 5, 21
PRINT "Choose a color for the jumproute:"
FOR tmp = 1 TO 15
LOCATE tmp + 6, 21: COLOR tmp
PRINT "("; CHR$(64 + tmp); ") "; colors$(tmp)
NEXT tmp
RETURN

5710 REM shift of sector
REM we know gal0$ & galdir$
REM we know xnow & ynow
sec0$ = sec$(FNsec(xnow, ynow), 1)
GOSUB 3800: REM file/directory paths
RETURN

5715 REM read configuration info
OPEN "i", 1, "gal.cfg"
LINE INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$: clrmode = VAL(RIGHT$(t$, 1))
CLOSE 1
RETURN

5720 REM read gals\where.dat
OPEN "i", 1, "gals\where.dat"
LINE INPUT #1, gal0$
tmp$ = LCASE$(LTRIM$(RTRIM$(gal0$)))
CLOSE 1
curgal = 1
FOR count = 1 TO numgals
 IF gals$(count, 1) = tmp$ THEN curgal = count
NEXT count
gal0$ = gals$(curgal, 1)
galdir$ = "gals\" + gal0$
RETURN

5722 REM write gals\where.dat
gal0$ = gals$(curgal, 1)
OPEN "o", 1, "gals\where.dat"
PRINT #1, gal0$
CLOSE 1
RETURN

5725 REM read gals\<sector>\where.dat
OPEN "i", 1, galdir$ + "\where.dat"
INPUT #1, xnow
INPUT #1, ynow
CLOSE 1
RETURN

5727 REM write gals\<sector>\where.dat
OPEN "o", 1, galdir$ + "\where.dat"
PRINT #1, xnow
PRINT #1, ynow
CLOSE 1
RETURN

5750 REM read galaxy list
OPEN "i", 1, "gals\gal.lst"
LINE INPUT #1, t$
LINE INPUT #1, t$
numgals = 0
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 t$ = RTRIM$(t$)
 IF t$ = "" GOTO 5755
 numgals = numgals + 1
 gals$(numgals, 1) = LCASE$(RTRIM$(LEFT$(t$, 8)))
 gals$(numgals, 2) = RIGHT$(t$, LEN(t$) - 13)
5755 LOOP
CLOSE 1
RETURN

5760 REM select galaxy
SCREEN 0: CLS : COLOR 10
PRINT "Galaxy Menu": PRINT
COLOR 11
IF numgals > 0 THEN
 FOR i = 1 TO numgals
  PRINT "    "; gals$(i, 2)
 NEXT i
ELSE
 PRINT "     <no galaxies present>"
END IF
COLOR 13
IF helptog = 1 THEN
 LOCATE 3, 40: PRINT "<Arrows>  Move Arrow"
 LOCATE 4, 40: PRINT "<Enter>   Select Galaxy"
 LOCATE 5, 40: PRINT " <Ins>    Create New Galaxy"
 LOCATE 6, 40: PRINT " <Del>    Delete Galaxy"
 LOCATE 7, 40: PRINT " F1/F2    Read/Edit Galaxy Notes"
 LOCATE 8, 40: PRINT "   F5     Sector Menu"
 LOCATE 9, 40: PRINT "   I      Import Galaxy from .gar file"
 LOCATE 10, 40: PRINT "   X      Export Galaxy to .gar file"
 LOCATE 11, 40: PRINT "   <      Edit gals\gal.lst"
 LOCATE 12, 40: PRINT "   >      Edit gals\<galaxy>\<galaxy>.lst"
 LOCATE 13, 40
ELSE
 LOCATE 3, 40
END IF
PRINT "   ?      Help Toggle"
5762 REM arrow
LOCATE curgal + 2, 2: COLOR 12
PRINT CHR$(196); CHR$(26)
5764 REM get input
GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 27 GOTO 5770: REM esc
IF k2 = 0 AND k1 = 81 GOTO 5770: REM Q 6,1
IF k2 = 0 AND k1 = 60 GOTO 5782: REM <
IF k2 = 0 AND (k1 = 63 OR k1 = 72) GOTO 5775: REM ?/H
IF k2 = 1 AND k1 = 82 GOTO 5780: REM insert (create)
IF k2 = 0 AND k1 = 73 GOTO 5790: REM I (import)
IF numgals = 0 GOTO 5764
IF k2 = 1 AND (k1 = 75 OR k1 = 77) GOTO 5766: REM left/right
IF k2 = 1 AND (k1 = 72 OR k1 = 80) GOTO 5766: REM up/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 5766: REM pgup/pgdn
IF k2 = 0 AND k1 = 13 GOTO 5768: REM enter
IF k2 = 0 AND k1 = 62 GOTO 5783: REM >
IF k2 = 1 AND k1 = 59 GOTO 5771: REM F1
IF k2 = 1 AND k1 = 60 GOTO 5772: REM F2
IF k2 = 1 AND k1 = 63 GOTO 5784: REM F5
IF k2 = 1 AND k1 = 83 GOTO 5785: REM delete
IF k2 = 0 AND k1 = 88 GOTO 5795: REM X (export)
GOTO 5764
5766 REM left/right/up/down/pgup/pgdn
LOCATE curgal + 2, 2: PRINT "  "
IF k1 = 72 OR k1 = 75 THEN curgal = curgal - 1
IF k1 = 80 OR k1 = 77 THEN curgal = curgal + 1
IF k1 = 73 THEN curgal = 1
IF k1 = 81 THEN curgal = numgals
IF curgal = 0 THEN curgal = numgals
IF curgal > numgals THEN curgal = 1
SOUND 10000, .1
GOTO 5762
5768 REM enter
gal0$ = gals$(curgal, 1)
galdir$ = "gals\" + gal0$
GOSUB 5722: REM write gals\where.dat
GOSUB 5725: REM read gals\<sector>\where.dat
GOSUB 3600: REM read list of sectors
sec0$ = sec$(FNsec(xnow, ynow), 1)
GOSUB 3800: REM file/directory paths
GOTO 3000: REM galaxy map
5770 REM esc
GOSUB 5722: REM write gals\where.dat
GOTO 10: REM main menu
5771 REM F1
gal0$ = gals$(curgal, 1)
SHELL "xtra\eg gals\" + gal0$ + "\gen\galaxy.mnu " + reader$
GOTO 5760
5772 REM F2
gal0$ = gals$(curgal, 1)
SHELL "xtra\eg gals\" + gal0$ + "\gen\galaxy.mnu " + editor$
GOTO 5760
5775 REM help toggle
IF helptog = 0 THEN helptog = 2
IF helptog = 1 THEN helptog = 0
IF helptog = 2 THEN helptog = 1
GOTO 5760
5780 REM create new galaxy
SHELL "sub\makegal"
GOTO 30
5782 REM edit gals\gal.lst
GOSUB 5500: REM egacolor
SHELL editor$ + " gals\gal.lst"
SCREEN 12: GOTO 30
5783 REM edit gals\<galaxy>\<galaxy>.lst
gal0$ = gals$(curgal, 1)
galdir$ = "gals\" + gal0$
seclist$ = galdir$ + "\" + gal0$ + ".lst"
GOSUB 5500: REM egacolor
SHELL editor$ + " " + seclist$
SCREEN 12: GOTO 5760
5784 REM sector menu
gal0$ = gals$(curgal, 1)
galdir$ = "gals\" + gal0$
seclist$ = galdir$ + "\" + gal0$ + ".lst"
SHELL "sub\secmnu " + seclist$
GOTO 5760
5785 REM delete galaxy
CLS
LOCATE 5
gal0$ = gals$(curgal, 1)
galdir$ = "gals\" + gal0$
CLS : COLOR 11: LOCATE 5
PRINT "Are you sure you want to delete ";
PRINT gals$(curgal, 2); "? (y/n)"
GOSUB 950
IF yn$ = "n" GOTO 5760
IF yn$ = "y" THEN
   CLS
   SHELL "deltree " + galdir$
   OPEN "i", 1, "gals\gal.lst"
   OPEN "o", 2, "gals\tmp.tmp"
   DO UNTIL EOF(1)
      LINE INPUT #1, t$
      IF RTRIM$(LEFT$(t$, 8)) <> gal0$ THEN PRINT #2, t$
   LOOP
   CLOSE 1
   CLOSE 2
   SHELL "del gals\gal.lst"
   SHELL "copy gals\tmp.tmp gals\gal.lst"
   SHELL "del gals\tmp.tmp"
   REM modify gals\where.dat
   IF curgal = numgals THEN curgal = curgal - 1
   IF curgal < 0 THEN curgal = 1
   GOSUB 5722: REM write gals\where.dat
END IF
GOTO 30
5790 REM import from archive
SHELL "xtra\ls *.gar > tmp.tmp"
OPEN "i", 1, "tmp.tmp"
l = LOF(1)
CLOSE 1
IF l = 0 THEN
   SHELL "del tmp.tmp"
   COLOR 11: CLS
   PRINT "There are no .gar files available for importing"
   GOSUB 900
END IF
IF l = 0 GOTO 5760
COLOR 11: CLS : PRINT "Files available for importing:": PRINT
SHELL "xtra\ls *.gar"
COLOR 10: PRINT
INPUT "Name of file to be imported: ", t$
t$ = LTRIM$(RTRIM$(LCASE$(t$)))
IF t$ = "" THEN SHELL "del tmp.tmp"
IF t$ = "" GOTO 5760
IF LEN(t$) < 4 THEN t$ = t$ + ".gar"
IF RIGHT$(t$, 4) <> ".gar" THEN t$ = t$ + ".gar"
ok = 0
OPEN "i", 1, "tmp.tmp"
DO UNTIL EOF(1)
 LINE INPUT #1, tmp$
 IF t$ = tmp$ THEN ok = 1
LOOP
CLOSE 1
SHELL "del tmp.tmp"
IF ok = 0 GOTO 5790
SHELL "sub\arch -d " + t$
GOTO 30
5795 REM export to archive
gal0$ = gals$(curgal, 1)
SHELL "sub\arch " + gal0$
GOTO 5760

5800 REM hooks
OPEN "i", 1, "data\hooks.dat"
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 t$ = RTRIM$(t$)
 IF t$ = "" GOTO 5810
 IF LEFT$(t$, 1) = "#" GOTO 5810
 l = LEN(t$)
 IF t$ = "Galaxy Map:" THEN
    a = 1: nhook%(1) = 0
 END IF
 IF t$ = "Text Sector Map:" THEN
    a = 2: nhook%(2) = 0
 END IF
 IF t$ = "Subsector Map:" THEN
    a = 3: nhook%(3) = 0
 END IF
 IF t$ = "Galaxy Map:" GOTO 5810
 IF t$ = "Text Sector Map:" OR t$ = "Subsector Map:" GOTO 5810
 nhook%(a) = nhook%(a) + 1
 IF MID$(t$, 10, 1) = "E" THEN hooke%(a, nhook%(a)) = 1
 IF MID$(t$, 10, 1) = "-" THEN hooke%(a, nhook%(a)) = 0
 hookac%(a, nhook%(a)) = VAL(MID$(t$, 11, 3))
 IF l > 59 THEN
    hookcom$(a, nhook%(a)) = RTRIM$(MID$(t$, 15, 45))
 ELSE
    hookcom$(a, nhook%(a)) = RTRIM$(RIGHT$(t$, l - 14))
 END IF
 IF l > 64 THEN
    hookspec$(a, nhook%(a)) = RTRIM$(MID$(t$, 60, 5))
 ELSEIF l > 59 AND l <= 64 THEN
    hookspec$(a, nhook%(a)) = RTRIM$(RIGHT$(t$, l - 59))
 ELSEIF l <= 59 THEN
    hookspec$(a, nhook%(a)) = ""
 END IF
5810 LOOP
CLOSE 1
RETURN

6000 REM set palette
SELECT CASE clrmode
CASE 1
   REM colors on black
   PALETTE
CASE 2
   REM colors on white
   PALETTE: PALETTE 0, 4144959: PALETTE 15, 0
CASE 3
   REM white on black
   t = 4144959
   PALETTE 0, 0: PALETTE 1, t: PALETTE 2, t: PALETTE 3, t
   PALETTE 4, t: PALETTE 5, t: PALETTE 6, t: PALETTE 7, t
   PALETTE 8, t: PALETTE 9, t: PALETTE 10, t: PALETTE 11, t
   PALETTE 12, t: PALETTE 13, t: PALETTE 14, t: PALETTE 15, t
CASE 4
   REM black on white
   PALETTE 0, 4144959: PALETTE 1, 0: PALETTE 2, 0: PALETTE 3, 0
   PALETTE 4, 0: PALETTE 5, 0: PALETTE 6, 0: PALETTE 7, 0
   PALETTE 8, 0: PALETTE 9, 0: PALETTE 10, 0: PALETTE 11, 0
   PALETTE 12, 0: PALETTE 13, 0: PALETTE 14, 0: PALETTE 15, 0
END SELECT
RETURN

9900 REM error
COLOR 7: CLS
PRINT "Error #"; LTRIM$(STR$(ERR)); " detected around line ";
PRINT LTRIM$(STR$(ERL)); ". Now Exiting Galactic."
PRINT
PRINT "Please report this error to jimv@empirenet.com"
PRINT "Let me know where it occured so I can examine the"
PRINT "code and see if there's a bug that needs squashing."
PRINT
PRINT "For the latest patches to this software, see my"
PRINT "homepage at http://members.aol.com/jimvassila, and"
PRINT "for the latest information about Galactic, join our"
PRINT "mailing list (see help\gml\signon.txt)."
PRINT
END

REM data
DATA "<reader>","<editor>","<galdir>","<secdir>","<seclist>"
DATA "<secfilepath>","<subfilepath>","<sublet>","<coord>"

10000 REM end
COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email:  jimv@empirenet.com"
PRINT "             jimvassila@aol.com"
PRINT
PRINT "  Homepage:  http://members.aol.com/jimvassila"
PRINT
END

