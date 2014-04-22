' galaxy/sector archiving/dearchiving utility
' for galactic v2.4
' public domain 1998 jim vassilakos
' jimv@empirenet.com / jimvassila@aol.com
'
' usage: arch <galaxy>            (archive galaxy)
'        arch -d <galaxy.gar>     (dearchive galaxy archive)
'        arch <galaxy>\<sector>   (archive sector)
'        arch -d <sector.sar>     (dearchive sector archive)

ver = 2.4
COLOR 11: PRINT ".": CLS
c$ = LCASE$(COMMAND$)
c$ = LTRIM$(RTRIM$(c$))
IF c$ = "" GOTO 1000
IF LEN(c$) <= 2 THEN GOTO 20
IF LEFT$(c$, 2) = "-d" THEN
   c$ = RIGHT$(c$, LEN(c$) - 3)
   IF RIGHT$(c$, 4) = ".gar" THEN mode = 2
   IF RIGHT$(c$, 4) = ".sar" THEN mode = 4
   c$ = LEFT$(c$, LEN(c$) - 4)
END IF
IF mode = 2 GOTO 200
IF mode = 4 GOTO 400
20 i = INSTR(c$, "\")
IF i = 0 GOTO 100
IF i > 0 GOTO 300

100 REM mode 1 - archive galaxy
IF LEN(c$) > 8 GOTO 1000
OPEN "i", 1, "gals\gal.lst"
LINE INPUT #1, t$
LINE INPUT #1, t$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF RTRIM$(LEFT$(t$, 8)) = c$ THEN s$ = RIGHT$(t$, LEN(t$) - 13)
LOOP
CLOSE 1
OPEN "o", 1, "gals\" + c$ + "\tmp.tmp"
   PRINT #1, ver
   PRINT #1, c$
   PRINT #1, s$
CLOSE 1
d$ = "xtra\pkzip -rP " + c$ + ".gar gals\" + c$ + "\*.*"
SHELL d$
SHELL "del gals\" + c$ + "\tmp.tmp"
CLS : LOCATE 5: PRINT "Created "; c$; ".gar"
GOSUB 950
GOTO 1000

200 REM mode 2 - dearchive galaxy
IF LEN(c$) > 8 GOTO 1000
d$ = "xtra\pkunzip -d " + c$ + ".gar"
SHELL d$
OPEN "i", 1, "gals\" + c$ + "\tmp.tmp"
INPUT #1, verarc
LINE INPUT #1, ck1$
LINE INPUT #1, s$
CLOSE 1
s2$ = c$ + SPACE$(13 - LEN(c$)) + s$
OPEN "a", 1, "gals\gal.lst"
PRINT #1, s2$
CLOSE 1
SHELL "del gals\" + c$ + "\tmp.tmp"
CLS : LOCATE 5: PRINT c$; ".gar has been dearchived"
IF c$ <> ck1$ THEN
 PRINT "There is a problem..."
 PRINT c$; ".gar has put the galaxy in gals\"; ck1$
 PRINT "whereas you seem to think it was heading toward gals\"; c$
 PRINT "This may cause problems..."
 PRINT "You will need to remove this galaxy or at least check"
 PRINT "all the .mnu files it contains."
END IF
GOSUB 800
GOSUB 950
GOTO 1000

300 REM mode 3 - archive sector
c1$ = LEFT$(c$, i - 1)
c2$ = RIGHT$(c$, LEN(c$) - i)
IF LEN(c1$) > 8 OR LEN(c2$) > 8 GOTO 1000
OPEN "i", 1, "gals\" + c1$ + "\" + c1$ + ".lst"
LINE INPUT #1, t$
LINE INPUT #1, t$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF RTRIM$(LEFT$(t$, 8)) = c2$ THEN s$ = t$
LOOP
CLOSE 1
OPEN "o", 1, "gals\" + c1$ + "\" + c2$ + "\tmp.tmp"
   PRINT #1, ver
   PRINT #1, c1$
   PRINT #1, c2$
   PRINT #1, s$
CLOSE 1
d$ = "xtra\pkzip -rP " + c2$ + ".sar gals\" + c1$ + "\" + c2$ + "\*.*"
SHELL d$
SHELL "del gals\" + c1$ + "\" + c2$ + "\tmp.tmp"
CLS : LOCATE 5: PRINT "Created "; c2$; ".sar"
GOSUB 950
GOTO 1000

400 REM mode 4 - dearchive sector
IF LEN(c$) > 8 GOTO 1000
d$ = "xtra\pkunzip -d " + c$ + ".sar"
SHELL d$
OPEN "i", 1, "gals\where.dat"
LINE INPUT #1, g$
CLOSE 1
OPEN "i", 1, "gals\" + g$ + "\" + c$ + "\tmp.tmp"
INPUT #1, verarc
LINE INPUT #1, ck1$
LINE INPUT #1, ck2$
LINE INPUT #1, s$
CLOSE 1
listfile$ = "gals\" + ck1$ + "\" + ck1$ + ".lst"
OPEN "i", 1, listfile$
OPEN "o", 2, "tmp.tmp"
hit = 0
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF RTRIM$(LEFT$(t$, 8)) = ck2$ THEN
      PRINT #2, s$
      hit = 1
   ELSE
      PRINT #2, t$
   END IF
LOOP
IF hit = 0 THEN PRINT #2, s$
CLOSE 1
CLOSE 2
SHELL "del " + listfile$
SHELL "copy tmp.tmp " + listfile$
SHELL "del tmp.tmp"
SHELL "del gals\" + g$ + "\" + c$ + "\tmp.tmp"
CLS : LOCATE 5: PRINT c$; ".sar has been dearchived"
IF g$ <> ck1$ OR c$ <> ck2$ THEN
 PRINT "There is a problem..."
 PRINT c$; ".gar has put the galaxy in gals\"; ck1$; "\"; ck2$
 PRINT "you seem to think it was heading toward gals\"; g$; "\"; c$
 PRINT "This may cause problems..."
 PRINT "You will need to remove this sector or at least check"
 PRINT "all the .mnu files it contains."
END IF
GOSUB 800
GOSUB 950
GOTO 1000

800 REM versions
IF ver <> verarc THEN
 PRINT "WARNING: This archive was created using Galactic ";
 PRINT LTRIM$(RTRIM$(STR$(verarc))); ","
 PRINT "   whereas you seem to be using Galactic"; ver$
 IF ver < verarc THEN
  PRINT "   You might want to consider upgrading to resolve"
  PRINT "   any potential incompatibility problems."
  PRINT
  PRINT "   Goto --> http://members.aol.com/jimvassila"
 END IF
 IF ver > verarc THEN
  PRINT "   There may be some data formatting adjustments that"
  PRINT "   you'll need to make."
 END IF
END IF
RETURN

900 REM pause
t$ = INKEY$
IF t$ <> "" GOTO 910
GOTO 900
910 RETURN

950 REM hit any key
LOCATE 15: PRINT "Hit any key to continue..."
GOSUB 900
RETURN

1000 REM end
END




