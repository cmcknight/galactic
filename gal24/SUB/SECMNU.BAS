DIM sec$(200, 2)
DIM col(200)

c$ = LCASE$(LTRIM$(RTRIM$(COMMAND$)))
REM c$ = "gals\classic\classic.lst"
IF c$ = "" GOTO 10000
i = INSTR(c$, "\")
i2 = INSTR(i + 1, c$, "\")
gal0$ = MID$(c$, i + 1, i2 - i - 1)
seclist$ = c$

GOSUB 600: REM read gal.cfg
GOSUB 700: REM read sectors list
p = 1: help = 1: devel = 0: delfiles = 0

SCREEN 0
10 CLS : COLOR 14
pg = INT((p - 1) / 20) + 1
PRINT "Directory of Sectors     -     Page"; pg;
IF devel = 1 THEN
   LOCATE , 50: PRINT "Gen";
   LOCATE , 60: PRINT "Loc";
END IF
PRINT
PRINT "-------------------------------------";
IF pg = 10 THEN PRINT "-";
IF devel = 1 THEN
   PRINT "--------------------------";
END IF
PRINT : PRINT
add = (pg - 1) * 20
FOR a = 1 + add TO 20 + add
 COLOR col(a)
 PRINT "     "; sec$(a, 2);
 IF devel = 1 AND sec$(a, 2) <> "" THEN
  delfiles = 1
  SHELL "dir /s/b gals\" + gal0$ + "\" + sec$(a, 1) + "\gen > tmp1.tmp"
  SHELL "dir /s/b gals\" + gal0$ + "\" + sec$(a, 1) + "\loc > tmp2.tmp"
  OPEN "i", 1, "tmp1.tmp": b1 = 0
  DO UNTIL EOF(1)
   LINE INPUT #1, tt$
   b1 = b1 + 1
  LOOP
  CLOSE 1
  OPEN "i", 1, "tmp2.tmp": b2 = 0
  DO UNTIL EOF(1)
   LINE INPUT #1, tt$
   b2 = b2 + 1
  LOOP
  CLOSE 1
  LOCATE , 50: PRINT b1 - 1;
  LOCATE , 60: PRINT b2;
 END IF
PRINT
NEXT a
IF help = 1 THEN
   COLOR 13: LOCATE 24, 70
   PRINT "(? = Help)";
END IF
help = 0

14 REM arrow
ar = p MOD 20
IF ar = 0 THEN ar = 20
LOCATE ar + 3, 2: COLOR 12
PRINT CHR$(196); CHR$(26)

15 REM get input
GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND k1 = 81 GOTO 10000: REM Q
IF k2 = 1 AND (k1 = 75 OR k1 = 77) GOTO 17: REM left/right
IF k2 = 1 AND (k1 = 72 OR k1 = 80) GOTO 17: REM up/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 17: REM pgup/pgdn
IF k2 = 0 AND k1 = 13 GOTO 18: REM enter
IF k2 = 0 AND k1 = 68 GOTO 16: REM D
IF k2 = 0 AND k1 = 69 GOTO 18: REM E
IF k2 = 0 AND k1 = 63 OR k1 = 72 GOTO 19: REM H/?
GOTO 15

16 REM Development Rating Toggle
IF devel = 0 THEN devel = 2
IF devel = 1 THEN devel = 0
IF devel = 2 THEN devel = 1
GOTO 10

17 REM up/down/pgup/pgdn
oldp = p
LOCATE ar + 3, 2: PRINT "  "
IF k1 = 72 OR k1 = 75 THEN p = p - 1
IF k1 = 80 OR k1 = 77 THEN p = p + 1
IF k1 = 73 THEN p = p - 20
IF k1 = 81 THEN p = p + 20
IF p > numsec THEN p = numsec
IF p < 1 THEN p = 1
IF INT((p - 1) / 20) <> INT((oldp - 1) / 20) GOTO 10
GOTO 14

18 REM enter
app$ = reader$
IF k1 = 69 THEN app$ = editor$
f$ = "gals\" + gal0$ + "\" + sec$(p, 1) + "\gen\sector.mnu"
SHELL "xtra\eg " + f$ + " " + app$
GOTO 10

19 REM commands list
CLS : COLOR 10
PRINT "List of Commands"
PRINT "----------------"
COLOR 11
PRINT
PRINT "   <Arrows>   Move Arrow"
PRINT "   <Enter>    View Sector Notes"
PRINT "     <E>      Edit Sector Notes"
PRINT "     <D>      Toggle Development Rating"
PRINT "   <Esc>/Q    Return to Galaxy Map"
PRINT : PRINT : COLOR 10
PRINT "Notes:"
PRINT : COLOR 11
PRINT "A sector's development rating is a set of two values,"
PRINT "'Gen' & 'Loc'. The former represents the number of"
PRINT "general information files the sector contains. The"
PRINT "latter represents the number of location-specific"
PRINT "files. Hexworld and Star System maps are not included"
PRINT "within either count and are essentially ignored in the"
PRINT "development rating. The whole purpose of this is to"
PRINT "give you a rough idea of the extent to which each"
PRINT "sector has been developed and to point to those which"
PRINT "need further work."
GOSUB 900
GOTO 10

600 REM read configuration info
OPEN "i", 1, "gal.cfg"
LINE INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
CLOSE 1
RETURN

700 REM read list of sectors
a = 0
OPEN "i", 1, seclist$
INPUT #1, t$
INPUT #1, t$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   t$ = LTRIM$(RTRIM$(t$))
   IF t$ = "" GOTO 710
   IF LEFT$(t$, 1) = "#" GOTO 710
   coltmp = ASC(MID$(t$, 61, 1)) - 65
   IF coltmp = 8 GOTO 710
   a = a + 1
   col(a) = coltmp
   sec$(a, 1) = RTRIM$(LEFT$(t$, 8))
   sec$(a, 2) = LTRIM$(RTRIM$(MID$(t$, 14, 37)))
710 LOOP
CLOSE 1
numsec = a
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

10000 REM end
COLOR 7
IF delfiles = 1 THEN
   SHELL "del tmp1.tmp"
   SHELL "del tmp2.tmp"
END IF
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email:  jimv@empirenet.com"
PRINT "             jimvassila@aol.com"
PRINT
PRINT "  Homepage:  http://members.aol.com/jimvassila"
END

