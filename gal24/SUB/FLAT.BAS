
REM FlatSec v1.1
REM Freeware 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com
REM Written in Microsoft QuickBasic version 4.5

DIM subname$(16, 2)
DIM world$(80)
DIM basalg$(2, 50, 2)
DIM basalgn(2)
DIM algncol(50)
DIM subtxt%(16)

IF COMMAND$ <> "" GOTO 5
CLS : COLOR 11
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 900
GOTO 10000

5 REM startover
zi = 1: zj = 1
GOSUB 5700: REM read configuration
GOSUB 2200: REM read sector file

SCREEN 12
GOTO 6000

900 REM get character from keyboard
k1 = 0: k2 = 0
910 k$ = INKEY$
IF k$ = "" THEN GOTO 910
k1 = ASC(k$)
IF k1 <> 0 THEN RETURN
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
RETURN

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

2200 REM get sector data
f$ = dir$ + secfile$
OPEN "i", 1, f$
LINE INPUT #1, secname$
LINE INPUT #1, temp$
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
44 REM get base & status info
i = 0
LINE INPUT #1, basalg$(j, i, 0)
i = 1
45 IF EOF(1) = -1 THEN GOTO 46
LINE INPUT #1, temp$
IF temp$ = "" THEN GOTO 46
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
GOTO 45
46 basalgn(j) = i - 1
IF j = 2 GOTO 48
j = j + 1
GOTO 44
48 CLOSE 1
RETURN

5700 REM read in settings
OPEN "i", 1, "gal.cfg"
INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
CLOSE 1
c$ = LCASE$(COMMAND$)
c$ = RIGHT$(c$, LEN(c$) - 5)
a = INSTR(c$, "\")
lc = LEN(c$)
galdir0$ = LEFT$(c$, a - 1)
galdir$ = "gals\" + galdir0$
l = LEN(galdir0$)
OPEN "i", 2, "gals\gal.lst"
INPUT #2, t$
INPUT #2, t$
DO UNTIL EOF(2)
   INPUT #2, t$
   t$ = RTRIM$(t$)
   IF t$ = "" GOTO 5705
   IF LEFT$(t$, l + 1) = galdir0$ + " " THEN
      l = LEN(t$)
      galname$ = RIGHT$(t$, l - 13)
   END IF
5705 LOOP
CLOSE 2
dir$ = RIGHT$(c$, lc - a)
nosector = 0
IF dir$ = "" THEN nosector = 1
5710 REM read in sector particulars
dir0$ = dir$
dir$ = galdir$ + "\" + dir$ + "\"
mapdir$ = dir$ + "map\"
locdir$ = dir$ + "loc\"
gendir$ = dir$ + "gen\"
hexdir$ = dir$ + "hex\"
secfile$ = dir0$ + ".dat"
CLOSE 1
l = LEN(dir0$)
IF nosector = 0 THEN
 OPEN "i", 1, galdir$ + "\" + galdir0$ + ".lst"
 INPUT #1, t$
 INPUT #1, t$
 DO UNTIL EOF(1)
    INPUT #1, t$
    t$ = RTRIM$(LEFT$(t$, 50))
    IF t$ <> "" THEN
       IF LEFT$(t$, l + 1) = dir0$ + " " THEN
          l = LEN(t$)
          secname2$ = RIGHT$(t$, l - 13)
       END IF
    END IF
 LOOP
 CLOSE 1
END IF
RETURN

hd = 0
6000 REM
OPEN "o", 1, "flat1"
FOR a = 1 TO 16
 fsub$ = mapdir$ + subname$(a, 2)
 OPEN "i", 2, fsub$
 DO UNTIL EOF(2)
  LINE INPUT #2, t$
  IF hd < 3 THEN
   IF LEFT$(t$, 7) = "#Planet" OR LEFT$(t$, 7) = "#------" THEN
    hd = hd + 1
    header$(hd) = t$
   END IF
  END IF
  IF LEN(t$) = 0 GOTO 6090
  IF INSTR("@#$", LEFT$(t$, 1)) <> 0 GOTO 6090
  PRINT #1, t$
  c$ = MID$(t$, 15, 4)
  c1 = VAL(LEFT$(c$, 2))
  c2 = VAL(RIGHT$(c$, 2))
  s$ = MID$(t$, 56, 2)
6090 LOOP
 CLOSE 2
NEXT a
CLOSE 1

SHELL "sort /+15 <flat1 >flat2"

OPEN "o", 1, dir0$ + ".sec"
PRINT #1, "# "; secname$; " / "; galname$
PRINT #1, "#"
FOR a = 1 TO 3
 PRINT #1, header$(a)
NEXT a
OPEN "i", 2, "flat2"
DO UNTIL EOF(2)
 LINE INPUT #2, t$
 PRINT #1, t$
LOOP
CLOSE
SHELL "erase flat1"
SHELL "erase flat2"

CLS : COLOR 11: LOCATE 10, 10
PRINT "Sector saved as "; dir0$; ".sec"
GOSUB 900

10000 REM end
COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email: jimv@empirenet.com"
PRINT "            jimvassila@aol.com"
END

