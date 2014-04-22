REM Galaxy Maker 1.0
REM Public Domain 1998 Jim Vassilakos

DIM gal$(15)
     
OPEN "i", 1, "gals\gal.lst"
LINE INPUT #1, t$
LINE INPUT #1, t$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   numgals = numgals + 1
   gal$(numgals) = LCASE$(RTRIM$(LEFT$(t$, 8)))
LOOP
CLOSE 1

CLS : COLOR 11
PRINT "The program will automatically create a directory for"
PRINT "your new galaxy to be placed into (which you must name)."
PRINT

COLOR 10
PRINT "Are you sure you really want to create a new galaxy?";
GOSUB 950
IF yn$ = "n" GOTO 1000
COLOR 12
PRINT "   Yes"
PRINT

COLOR 11
PRINT "Enter the Name of the Galaxy (40 characters max):"
PRINT "   (For example: The Milky Way)";

20 LOCATE 9, 1: PRINT SPACE$(70);
LOCATE 9, 1
INPUT "--->", t$
IF t$ = "" GOTO 20
t$ = LTRIM$(RTRIM$(t$))
IF LEN(t$) > 40 GOTO 20
PRINT
galname$ = t$

PRINT "You galaxy will be placed under the 'gals' directory."
PRINT "Please provide a directory name (8 characters or less):"
PRINT
30 LOCATE 14, 1
PRINT SPACE$(70)
LOCATE 14, 1: INPUT "--->", t$
t$ = LCASE$(LTRIM$(RTRIM$(t$)))
IF t$ = "" GOTO 30
l = LEN(t$)
IF RIGHT$(t$, 1) = "\" THEN
   l = l - 1
   t$ = LEFT$(t$, l)
END IF
ok = 1
FOR a = 1 TO numgals
IF t$ = gal$(a) THEN ok = 2
NEXT a
IF INSTR(t$, ".") > 0 THEN ok = 4
IF l > 8 THEN ok = 3
IF ok = 2 THEN PRINT "   <directory already exists, try again>"
IF ok = 3 THEN PRINT "   <8 characters maximum, try again>    "
IF ok = 4 THEN PRINT "   <no extension required, try again>   "
IF ok <> 1 GOTO 30
gal0$ = t$
dir$ = "gals\" + t$

REM update gal.lst
l = LEN(gal0$)
t$ = gal0$ + SPACE$(13 - l) + galname$
OPEN "a", 1, "gals\gal.lst"
PRINT #1, t$
CLOSE 1

REM create galaxy's directories
SHELL "mkdir " + dir$
SHELL "mkdir " + dir$ + "\gen"

REM create galaxy's list file
OPEN "o", 1, dir$ + "\" + gal0$ + ".lst"
PRINT #1, "Directory of Sectors"
PRINT #1, "-------------------------------------------------------------"
CLOSE 1

REM create general info menu
OPEN "o", 1, dir$ + "\gen\galaxy.mnu"
PRINT #1, "@dir="; dir$; "\gen"
PRINT #1, "@Light Yellow"
PRINT #1, ""
PRINT #1, galname$; " / General Information"
PRINT #1, ""
PRINT #1, ""
PRINT #1, "@Light Cyan"
PRINT #1, "      Topics & Methods       @ideas.txt"
CLOSE 1

REM create ideas.txt, uwp.dat, where.dat
SHELL "copy help\ideas.txt " + dir$ + "\gen"
SHELL "copy data\uwp.dat " + dir$
OPEN "o", 1, dir$ + "\where.dat"
PRINT #1, "0": PRINT #1, "0"
CLOSE 1
GOTO 1000

REM modify gals\where.dat
OPEN "o", 1, "gals\where.dat"
PRINT #1, gal0$
CLOSE 1

900 REM read keyboard
k1 = 0: k2 = 0
902 k$ = INKEY$
IF k$ = "" THEN GOTO 902
SOUND 10000, .1
k1 = ASC(k$)
IF k1 <> 13 THEN GOTO 903
FOR note = 1 TO 10
SOUND note * 200, .1
NEXT note
903 IF k1 <> 0 THEN GOTO 904
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
904 RETURN

950 REM y/n
yn$ = ""
GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 78 THEN yn$ = "n": REM N
IF k2 = 0 AND k1 = 89 THEN yn$ = "y": REM Y
IF yn$ = "" GOTO 950
RETURN

1000 REM
COLOR 7: CLS
PRINT "Later..."
END

