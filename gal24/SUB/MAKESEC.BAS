REM Galactic Sector Creation Questionnaire v1.0
REM Public Domain 1998 Jim Vassilakos

DIM subname$(16)
DIM subdir$(16)
DIM sod(16)
DIM soc$(16)
DIM ac$(15)
DIM ad$(15)
DIM acol(15)
DIM col$(15)
DIM subalg$(16)

dirname$ = LCASE$(COMMAND$)
gener = 0

REM read gal.cfg
OPEN "i", 1, "gal.cfg"
LINE INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
CLOSE 1

REM read colors.dat
OPEN "i", 1, "xtra\colors.dat"
LINE INPUT #1, t$
FOR a = 1 TO 15
   LINE INPUT #1, t$
   col$(a) = RIGHT$(t$, LEN(t$) - 4)
NEXT a
CLOSE 1

REM read gals\where.dat
OPEN "i", 1, "gals\where.dat"
LINE INPUT #1, gal0$
CLOSE 1
galdir$ = "gals\" + gal0$
seclist$ = galdir$ + "\" + gal0$ + ".lst"

IF dirname$ = "" GOTO 100

REM determine secname$ based on dirname$
OPEN "i", 1, seclist$
LINE INPUT #1, t$
LINE INPUT #1, t$
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 IF RTRIM$(LEFT$(t$, 8)) = dirname$ THEN
  secname$ = RTRIM$(MID$(t$, 14, 35))
 END IF
LOOP
CLOSE 1

100 SCREEN 0: CLS : COLOR 11
PRINT "The program will automatically create a directory for"
PRINT "your new sector to be placed into ";
IF dirname$ = "" THEN
 PRINT "(which you must name)."
ELSE
 PRINT "("; galdir$; "\"; dirname$; ")."
END IF
PRINT
PRINT "In addition, there will be five subdirectories:"
PRINT : COLOR 13
PRINT "   gen: containing general information"
PRINT "   loc: containing location (world) notes"
PRINT "   map: containing subsector maps"
PRINT "   hex: containing hexworld maps"
PRINT "   sys: containing starsystem maps"
PRINT : COLOR 11
PRINT "You will also be prompted to supply information about the"
PRINT "sector to be created (subsector names, stellar population"
PRINT "density, societal level, etc)."
PRINT

COLOR 10
PRINT "Are you sure you really want to create a new sector?";
460 GOSUB 6000
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 89 GOTO 465: REM Y
IF k2 = 0 AND k1 = 78 GOTO 10000: REM N
GOTO 460
465 CLS

IF dirname$ <> "" GOTO 1000

COLOR 10
PRINT "Enter the Name of the Sector (40 characters max)"
PRINT "   (For example: The Spinward Marches)"
locline = 4
470 LOCATE locline, 1: PRINT SPACE$(70);
LOCATE locline, 1: COLOR 11
INPUT "--->", t$
IF t$ = "" GOTO 470
t$ = LTRIM$(RTRIM$(t$))
IF LEN(t$) > 40 GOTO 470
PRINT
secname$ = t$

locline = locline + 4: COLOR 10
PRINT "Please provide a directory name (8 characters or less)"
PRINT
480 LOCATE locline, 1
PRINT SPACE$(70)
LOCATE locline, 1: COLOR 11: INPUT "--->", t$
t$ = LCASE$(LTRIM$(RTRIM$(t$)))
IF t$ = "" GOTO 480
l = LEN(t$)
IF RIGHT$(t$, 1) = "\" THEN
   l = l - 1
   t$ = LEFT$(t$, l)
END IF
ok = 1

OPEN "i", 1, seclist$
LINE INPUT #1, t1$
LINE INPUT #1, t1$
DO UNTIL EOF(1)
 LINE INPUT #1, t1$
 IF t$ = RTRIM$(LEFT$(t1$, 8)) THEN ok = 2
LOOP
CLOSE 1

IF INSTR(t$, ".") > 0 THEN ok = 4
IF l > 8 THEN ok = 3
IF ok = 2 THEN PRINT "   <directory already exists, try again>"
IF ok = 3 THEN PRINT "   <8 characters maximum, try again>    "
IF ok = 4 THEN PRINT "   <no extension required, try again>   "
IF ok <> 1 GOTO 480
dirname$ = t$

1000 REM new sector set-up
CLS : COLOR 14
PRINT "New Sector Creation"
PRINT : COLOR 11
PRINT "   Sector Name: "; secname$
PRINT "   Directory: "; dirname$
PRINT
COLOR 10
PRINT "Step 1: Assign name of each subsector"
PRINT "Step 2: Assign filename for each subsector"
PRINT "Step 3: Assign stellar probability percentages"
PRINT "Step 4: Assign societal levels"
PRINT "Step 5: Define allegiance codes"
PRINT "Step 6: Assign principle allegiance codes"
PRINT : PRINT : GOSUB 9100
1010 IF novice = 0 GOTO 1020
PRINT "   Hit any key to continue..."
GOSUB 6000
GOTO 1100

1020 COLOR 11
PRINT "You have two options:"
PRINT
PRINT "(1) Go through a 6-step questionnaire to create your own"
PRINT "    sector generation setup file: data\secgen.dat"
PRINT
PRINT "(2) Edit the current sector generation setup file"
PRINT "    directly (not recommended unless you think you know"
PRINT "    what you're doing)."
PRINT
1050 GOSUB 6000
IF k2 = 0 AND k1 = 49 GOTO 1100: REM 1
IF k2 = 0 AND k1 = 50 GOTO 1060: REM 2
GOTO 1050

1060 REM fix secgen.dat's top two lines
SHELL "copy data\secgen.dat data\tmp.tmp"
OPEN "i", 1, "data\tmp.tmp"
OPEN "o", 2, "data\secgen.dat"
LINE INPUT #1, t$
LINE INPUT #1, t$
LINE INPUT #1, t$
PRINT #2, "sector:"; secname$
PRINT #2, "galdir:"; gal0$
PRINT #2, "secdir:"; dirname$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   PRINT #2, t$
LOOP
CLOSE 1
CLOSE 2
SHELL "erase data\tmp.tmp"
GOTO 2070

1100 REM step 1
CLS : COLOR 14
PRINT "Step 1: Assign name of each subsector"
GOSUB 9300: REM 4*4 grid
COLOR 11
FOR i = 1 TO 4
FOR j = 1 TO 4
   k = j + ((i - 1) * 4)
1150 LOCATE i * 5 + (k + 1) MOD 2, (j - 1) * 15 + 2
   PRINT SPACE$(14);
   LOCATE i * 5 + (k + 1) MOD 2, (j - 1) * 15 + 2
   INPUT ">", t$
   t$ = LTRIM$(RTRIM$(t$))
   ok = 1
   IF LEN(t$) > 25 OR t$ = "" THEN ok = 0
   IF ok = 1 THEN subname$(k) = t$
   IF ok = 0 THEN GOTO 1150
NEXT j
NEXT i
COLOR 12: LOCATE 23, 1
PRINT "Is all the information here correct? (y/n) "
GOSUB 9000
IF yn$ = "n" GOTO 1100

1200 REM step 2
CLS : COLOR 14
PRINT "Step 2: Assign filename for each subsector"
PRINT "   (8 chars max, no extension)"
GOSUB 9300: REM 4*4 grid
GOSUB 9350: REM subsector names
COLOR 11
FOR i = 1 TO 4
FOR j = 1 TO 4
   k = j + ((i - 1) * 4)
1250 LOCATE i * 5 + 1, (j - 1) * 15 + 2
   PRINT SPACE$(14);
   LOCATE i * 5 + 1, (j - 1) * 15 + 2
   INPUT ">", t$
   t$ = LTRIM$(RTRIM$(t$))
   ok = 1
   IF LEN(t$) > 8 OR t$ = "" THEN ok = 0
   IF INSTR(t$, ".") > 0 THEN ok = 0
   IF k > 1 THEN
      FOR tmp = 1 TO k - 1
         IF t$ = subdir$(tmp) THEN ok = 0
      NEXT tmp
   END IF
   IF ok = 1 THEN subdir$(k) = t$
   IF ok = 0 THEN GOTO 1250
NEXT j
NEXT i
COLOR 12: LOCATE 23, 1
PRINT "Is all the information here correct? (y/n) "
GOSUB 9000
IF yn$ = "n" GOTO 1200

1300 REM step 3
CLS : COLOR 14
PRINT "Step 3: Assign stellar probability percentages  (0-100)"
GOSUB 9300: REM 4*4 grid
GOSUB 9350: REM subsector names
COLOR 11
FOR i = 1 TO 4
FOR j = 1 TO 4
   k = j + ((i - 1) * 4)
1350 LOCATE i * 5 + 1, (j - 1) * 15 + 2
   PRINT SPACE$(14);
   LOCATE i * 5 + 1, (j - 1) * 15 + 2
   INPUT ">", t$
   t$ = LTRIM$(RTRIM$(t$))
   t = VAL(t$)
   ok = 1
   IF t > 100 OR t < 0 THEN ok = 0
   IF t$ <> LTRIM$(RTRIM$(STR$(INT(t)))) THEN ok = 0
   IF ok = 1 THEN sod(k) = t
   IF ok = 0 THEN GOTO 1350
NEXT j
NEXT i
COLOR 12: LOCATE 23, 1
PRINT "Is all the information here correct? (y/n) "
GOSUB 9000
IF yn$ = "n" GOTO 1300

1400 REM step 4
CLS : COLOR 14
PRINT "Step 4: Assign societal levels  (careful: keys are hot)"
PRINT "U=Unsettled  B=Backwater  S=Standard  M=Mature  C=Economic Hub"
GOSUB 9300: REM 4*4 grid
GOSUB 9350: REM subsector names
COLOR 13
FOR i = 1 TO 4
FOR j = 1 TO 4
   LOCATE i * 5, (j - 1) * 15 + 2
   PRINT " "; RTRIM$(STR$(sod(j + ((i - 1) * 4)))) + "%";
NEXT j
NEXT i
COLOR 11
FOR i = 1 TO 4
FOR j = 1 TO 4
   k = j + ((i - 1) * 4)
1450 LOCATE i * 5 + 1, (j - 1) * 15 + 2
   PRINT ">";
   GOSUB 6000
   t$ = ""
   IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
   IF k2 = 0 AND k1 = 85 THEN t$ = "U": REM U
   IF k2 = 0 AND k1 = 66 THEN t$ = "B": REM B
   IF k2 = 0 AND k1 = 83 THEN t$ = "S": REM S
   IF k2 = 0 AND k1 = 77 THEN t$ = "M": REM M
   IF k2 = 0 AND k1 = 67 THEN t$ = "C": REM C
   IF t$ = "" THEN GOTO 1450
   IF t$ <> "" THEN
      LOCATE i * 5 + 1, (j - 1) * 15 + 3
      IF t$ = "U" THEN PRINT "Unsettled";
      IF t$ = "B" THEN PRINT "Backwater";
      IF t$ = "S" THEN PRINT "Standard";
      IF t$ = "M" THEN PRINT "Mature";
      IF t$ = "C" THEN PRINT "Economic Hub";
      soc$(k) = t$
   END IF
NEXT j
NEXT i
COLOR 12: LOCATE 23, 1
PRINT "Is all the information here correct? (y/n) "
GOSUB 9000
IF yn$ = "n" GOTO 1400

1500 REM step 5
CLS : COLOR 14
PRINT "Step 5: Define allegiance codes"
PRINT : COLOR 11
PRINT "Each world generated has a two-character allegiance code"
PRINT "in order to show what interstellar government, if any, it"
PRINT "is a part of (Imperial, Zhodani, etc). A different color"
PRINT "is associated with each of these allegiance codes so that"
PRINT "you can tell, at a glance, what nation any particular"
PRINT "world belongs to. Here is a list of the allegiance codes"
PRINT "and their respective definitions used as part of the"
PRINT "Spinward Marches Sector. Just to give you an idea of what"
PRINT "we're talking about."
PRINT ""
COLOR 10
PRINT "Im = Imperial     As = Aslan            Zh = Zhodani"
PRINT "Va = Vargr        Sw = Sword Worlds     Da = Darrian"
PRINT "Dr = Droyne       Na = Non-aligned      Cs = Client State"
PRINT "Fa = Federation of Arden                   = Unknown"
1510 LOCATE 18, 1: COLOR 11
PRINT SPACE$(75): PRINT SPACE$(75): LOCATE 18, 1
PRINT "How many allegiance codes do you want to define for the"
PRINT "sector that you are creating? (1-15)  ";
INPUT "", num
IF num < 0 OR num > 15 THEN GOTO 1510
CLS : COLOR 14
PRINT "Step 5: Define principle allegiance codes"
PRINT "   (Code must be 2 chars, definition can be up to 22)"
PRINT
COLOR 10
PRINT "    Code  Definition"
PRINT "    ----  ----------------------"
COLOR 11
FOR a = 1 TO num
PRINT a
NEXT a
FOR a = 1 TO num
   both = 0
   LOCATE a + 5, 6
   PRINT SPACE$(70)
   LOCATE a + 5, 6
   INPUT "", t$
   t$ = LTRIM$(RTRIM$(t$))
   IF LEN(t$) > 5 THEN
      both = 1
      t2$ = RIGHT$(t$, LEN(t$) - 5)
      t$ = LEFT$(t$, 2)
   END IF
   ok = 1
   IF LEN(t$) <> 2 THEN ok = 0
   REM make sure it's not a duplicate
   IF a > 1 THEN
      FOR b = 1 TO a - 1
         IF t$ = ac$(b) THEN ok = 0
      NEXT b
   END IF
   IF ok = 0 THEN a = a - 1
   IF ok = 0 GOTO 1520
   IF ok = 1 THEN ac$(a) = t$
   IF both = 0 THEN
      LOCATE a + 5, 11
      INPUT "", t$
   END IF
   IF both = 1 THEN t$ = t2$
   t$ = LTRIM$(RTRIM$(t$))
   IF LEN(t$) = 0 OR LEN(t$) > 22 THEN ok = 0
   IF ok = 0 THEN a = a - 1
   IF ok = 1 THEN ad$(a) = t$
1520 NEXT a
PRINT : COLOR 12
PRINT "Is all the information here correct? (y/n) "
GOSUB 9000
IF yn$ = "n" GOTO 1500

1550 REM step 5b
CLS : COLOR 14
PRINT "Step 5: Define principle allegiance codes"
PRINT "    Section B: Define Colors"
PRINT : COLOR 10
PRINT "    Code  Definition              Color"
PRINT "    ----  ----------------------  ------------------"
LOCATE 7 + num
COLOR 12
PRINT "Use the arrow keys. Hit <return> when satisfied."
b = 1
FOR a = 1 TO num
   acol(a) = a MOD 5 + 9
NEXT a
1560 FOR a = 1 TO num
   LOCATE a + 5, 1: PRINT SPACE$(75): LOCATE a + 5, 1
   COLOR acol(a): PRINT "     "; ac$(a); "   "; ad$(a);
   PRINT SPACE$(24 - LEN(ad$(a))); "#";
   PRINT LTRIM$(STR$(acol(a))); ": "; col$(acol(a))
NEXT a
COLOR 12: LOCATE b + 5, 2
PRINT CHR$(196); CHR$(26)
1570 GOSUB 6000
IF k2 = 1 AND k1 = 72 GOTO 1575: REM up
IF k2 = 1 AND k1 = 80 GOTO 1580: REM down
IF k2 = 1 AND k1 = 75 GOTO 1585: REM left
IF k2 = 1 AND k1 = 77 GOTO 1590: REM right
IF k2 = 0 AND k1 = 13 THEN GOTO 1600: REM enter
GOTO 1570
1575 REM up
b = b - 1: IF b < 1 THEN b = num
GOTO 1560
1580 REM down
b = b + 1: IF b > num THEN b = 1
GOTO 1560
1585 REM left
acol(b) = acol(b) - 1
IF acol(b) < 1 THEN acol(b) = 15
GOTO 1560
1590 REM right
acol(b) = acol(b) + 1
IF acol(b) > 15 THEN acol(b) = 1
GOTO 1560

1600 REM step 6
CLS : COLOR 14
PRINT "Step 6: Assign principle allegiance codes"
COLOR 11
PRINT "Possible Codes: ";
FOR a = 1 TO num
   PRINT ac$(a);
   IF a <> num THEN PRINT ", ";
NEXT a
PRINT "."
GOSUB 9300: REM 4*4 grid
GOSUB 9350: REM subsector names
COLOR 11
FOR i = 1 TO 4
FOR j = 1 TO 4
   k = j + ((i - 1) * 4)
1650 LOCATE i * 5 + 1, (j - 1) * 15 + 2
   PRINT SPACE$(14);
   LOCATE i * 5 + 1, (j - 1) * 15 + 2
   INPUT ">", t$
   t$ = LTRIM$(RTRIM$(t$))
   ok = 0
   FOR b = 1 TO num
      IF t$ = ac$(b) THEN ok = 1
   NEXT b
   IF ok = 1 THEN subalg$(k) = t$
   IF ok = 0 THEN GOTO 1650
NEXT j
NEXT i
COLOR 12: LOCATE 23, 1
PRINT "Is all the information here correct? (y/n) "
GOSUB 9000
IF yn$ = "n" GOTO 1600

2000 REM write secgen.dat
OPEN "o", 1, "data\secgen.dat"
OPEN "i", 2, "data\secgen2.dat"
PRINT #1, "sector:"; secname$
PRINT #1, "galdir:"; gal0$
PRINT #1, "secdir:"; dirname$
GOSUB 9200
FOR a = 1 TO 16
   PRINT #1, CHR$(a + 64); ": ";
   PRINT #1, subname$(a);
   PRINT #1, SPACE$(27 - LEN(subname$(a)));
   PRINT #1, subdir$(a);
   PRINT #1, SPACE$(10 - LEN(subdir$(a)));
   sod$ = LTRIM$(RTRIM$(STR$(sod(a))))
   PRINT #1, sod$;
   PRINT #1, SPACE$(5 - LEN(sod$));
   PRINT #1, soc$(a); "  ";
   PRINT #1, subalg$(a)
NEXT a
GOSUB 9200
FOR a = 1 TO num
   PRINT #1, ac$(a); "  ";
   PRINT #1, ad$(a);
   PRINT #1, SPACE$(23 - LEN(ad$(a)));
   PRINT #1, acol(a)
NEXT a
GOSUB 9200
CLOSE 1
CLOSE 2

2050 REM
CLS : COLOR 14
PRINT "What now, Boss?"
PRINT : COLOR 11
PRINT "The information you have entered has been saved to the"
PRINT "file 'data\secgen.dat' which is the setup file for"
PRINT "sector generation.";
IF novice = 0 THEN PRINT
IF novice = 1 THEN
PRINT " In the future, you may choose to edit"
PRINT "this file directly rather than going through the"
PRINT "questionnaire process you've just been subjected to. The"
PRINT "main problem with editing the file directly is that there"
PRINT "are lots of opportunities to screw-up, so for non-"
PRINT "advanced users, the questionnaire method is suggested."
END IF
PRINT
2060 REM
COLOR 14
PRINT "At this point, you have three options:"
PRINT ""
COLOR 10
PRINT "(1) Bail Out (skip sector generation entirely)"
PRINT "(2) Edit data\secgen.dat directly"
PRINT "(3) Generate Sector"
PRINT
2065 GOSUB 6000
IF k2 = 0 AND k1 = 49 GOTO 10000: REM 1
IF k2 = 0 AND k1 = 50 GOTO 2070: REM 2
IF k2 = 0 AND k1 = 51 GOTO 2080: REM 3
GOTO 2065

2070 REM edit data\secgen.dat
COLOR 7: CLS : PRINT "."
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
SHELL editor$ + " data\secgen.dat"
SCREEN 12: SCREEN 0: CLS : GOTO 2060

2080 REM
gener = 1
GOTO 10000

6000 REM read keyboard
k1 = 0: k2 = 0
6002 k$ = INKEY$
IF k$ = "" THEN GOTO 6002
SOUND 10000, .1
k1 = ASC(k$)
IF k1 <> 13 THEN GOTO 6003
FOR note = 1 TO 10
SOUND note * 200, .1
NEXT note
6003 IF k1 <> 0 THEN GOTO 6004
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
6004 RETURN

9000 REM y/n
yn$ = ""
GOSUB 6000
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 78 THEN yn$ = "n": REM N
IF k2 = 0 AND k1 = 89 THEN yn$ = "y": REM Y
IF yn$ = "" GOTO 9000
RETURN

9100 REM does data\secgen.dat exist?
novice = 0
OPEN "r", 1, "data\secgen.dat"
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN SHELL "erase data\secgen.dat"
IF exist = 0 THEN novice = 1
RETURN

9200 REM sector.hlp read/writer
INPUT #2, a
FOR b = 1 TO a
LINE INPUT #2, a$
PRINT #1, a$
NEXT b
RETURN

9300 REM draw subsector boxes
COLOR 2
LOCATE 3, 1: PRINT CHR$(201);
LOCATE 23, 61: PRINT CHR$(188);
LOCATE 3, 61: PRINT CHR$(187);
LOCATE 23, 1: PRINT CHR$(200);
FOR i = 16 TO 46 STEP 15
LOCATE 3, i: PRINT CHR$(203);
LOCATE 23, i: PRINT CHR$(202);
NEXT i
FOR i = 8 TO 18 STEP 5
LOCATE i, 1: PRINT CHR$(204);
LOCATE i, 61: PRINT CHR$(185);
NEXT i
FOR i = 16 TO 46 STEP 15
FOR j = 8 TO 18 STEP 5
LOCATE j, i: PRINT CHR$(206);
NEXT j
NEXT i
FOR i = 1 TO 46 STEP 15
FOR j = 1 TO 14
FOR k = 3 TO 23 STEP 5
LOCATE k, i + j: PRINT CHR$(205);
NEXT k
NEXT j
NEXT i
FOR i = 3 TO 18 STEP 5
FOR j = 1 TO 4
FOR k = 1 TO 61 STEP 15
LOCATE i + j, k: PRINT CHR$(186);
NEXT k
NEXT j
NEXT i
RETURN

9350 REM show subsector names
COLOR 14
FOR i = 1 TO 4
FOR j = 1 TO 4
   tmp$ = subname$(j + ((i - 1) * 4))
   IF LEN(tmp$) > 14 THEN tmp$ = LEFT$(tmp$, 14)
   LOCATE i * 5 - 1, (j - 1) * 15 + 2
   PRINT tmp$;
NEXT j
NEXT i
RETURN

10000 REM
OPEN "o", 1, "secgen.tmp"
IF gener = 1 THEN
 PRINT #1, "full steam ahead"
ELSE
 PRINT #1, "stop"
END IF
CLOSE 1
COLOR 7: CLS
PRINT "Been fun..."
END

