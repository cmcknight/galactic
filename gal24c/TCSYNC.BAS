
REM Trade Code Syncronizer v1.0
REM Public Domain 2000 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com

REM Usage = tcsync sec <secdir>
REM         tcsync sub <subfilepath>
REM i.e. tcsync sec gals\classic\spinmar
REM i.e. tcsync sub gals\classic\spinmar\map\mora.dat

DIM tccode$(15)
DIM tc(15)
DIM subsec$(2, 16): REM names & filenames of subsectors

DEF fnnum (f11$)
   IF f11$ = LTRIM$(STR$(VAL(f11$))) THEN f12 = VAL(f11$)
   IF f11$ <> LTRIM$(STR$(VAL(f11$))) THEN
      f12 = ASC(f11$) - 55
   END IF
   fnnum = f12
END DEF

SCREEN 0
c$ = COMMAND$
REM c$ = "sec gals\classic\spinmar"
REM c$ = "sub gals\classic\spinmar\map\mora.dat"

c$ = LCASE$(LTRIM$(RTRIM$(c$)))
IF c$ = "" GOTO 10
scope$ = LEFT$(c$, 3)
c$ = RIGHT$(c$, LEN(c$) - 4)
IF scope$ = "sec" THEN
 i = INSTR(6, c$, "\")
 l = LEN(c$)
 secdir$ = c$ + "\": REM secdir$ = "gals\var1\gythios\"
 secfile$ = secdir$ + RIGHT$(c$, l - i) + ".dat"
 REM secfile$ = "gals\var1\gythios\gythios.dat"
 mapdir$ = secdir$ + "map\": REM mapdir$ = "gals\var1\gythios\map\"
END IF
IF scope$ = "sub" THEN subfile$ = c$

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
IF scope$ = "sec" THEN GOSUB 5800: REM read sector file
GOSUB 5850: REM read trade codes
method = 1: arrow = 1: arrow2 = 1

100 SCREEN 0: CLS : COLOR 10: PRINT
PRINT "Trade Code Synchronizer"
PRINT "Public Domain 2000 Jim Vassilakos"
PRINT : PRINT : COLOR 11
PRINT "     What's the Big Idea?"
PRINT
PRINT "     We're Using the ";
IF method = 1 THEN PRINT "Standard";
IF method = 2 THEN PRINT "Homebrew";
PRINT " Method"
PRINT
PRINT "     Sync the ";
IF scope$ = "sec" THEN PRINT "Sector!"
IF scope$ = "sub" THEN PRINT "Subsector!"
PRINT
PRINT "     Get Me Outta Here!"
110 REM arrow
COLOR 12: LOCATE 4 + arrow * 2, 3
PRINT CHR$(196); CHR$(26)

120 REM get input
GOSUB 1000
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND (k1 = 27 OR k1 = 81) GOTO 10000: REM esc/q
IF k2 = 1 AND (k1 = 75 OR k1 = 72) THEN GOTO 130: REM left/up
IF k2 = 1 AND (k1 = 77 OR k1 = 80) THEN GOTO 130: REM right/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 130: REM pgup/pgdn
IF k2 = 0 AND k1 = 13 GOTO 140: REM enter
GOTO 120

130 REM arrow movement
LOCATE 4 + arrow * 2, 3
PRINT "  "
IF k1 = 72 OR k1 = 75 THEN arrow = arrow - 1
IF k1 = 80 OR k1 = 77 THEN arrow = arrow + 1
IF k1 = 73 THEN arrow = 1
IF k1 = 81 THEN arrow = 0
IF arrow = 0 THEN arrow = 4
IF arrow = 5 THEN arrow = 1
SOUND 10000, .1
GOTO 110

140 REM enter
IF arrow = 1 GOTO 150
IF arrow = 2 GOTO 160
IF arrow = 3 GOTO 170
IF arrow = 4 GOTO 10000

150 REM help
GOSUB 5500: REM egacolor
SHELL reader$ + " help\tcsync.txt"
SCREEN 12
GOTO 100

160 REM change method
IF method = 1 THEN method = 0
IF method = 2 THEN method = 1
IF method = 0 THEN method = 2
GOTO 100

170 REM sync sector
REM file1 = log of proposed changes (temporary)
REM file2 = subsector file being read
REM file3 = fixed subsector file being written (temporary)
OPEN "o", 1, "tmplog.tmp"
PRINT #1, ""
PRINT #1, "This is a log of the proposed changes to your ";
IF scope$ = "sec" THEN PRINT #1, "sector"
IF scope$ = "sub" THEN PRINT #1, "subsector"
PRINT #1, "so that the trade codes will properly conform to the UWPs."
PRINT #1, "You will be given the option to either accept or reject"
PRINT #1, "these proposed changes."
PRINT #1, ""
PRINT #1, ""
IF scope$ = "sub" THEN
   subfile2$ = "tmpsub.tmp"
   GOSUB 300
END IF
IF scope$ = "sec" THEN
 FOR a = 1 TO 16
  subfile$ = mapdir$ + subsec$(2, a)
  subfile2$ = "tmp-" + LCASE$(CHR$(a + 64)) + ".tmp"
  GOSUB 300
 NEXT a
END IF
CLOSE 1
REM read the log
GOSUB 5500: REM egacolor
SHELL reader$ + " tmplog.tmp"
SCREEN 12

200 SCREEN 0: CLS : COLOR 10: PRINT
PRINT "Now that you've seen the log and are aware of what will"
PRINT "happen, do you want to proceed with these trade code"
PRINT "modifications, or would you rather bail out now while"
PRINT "you still can w/o modifying anything?"
PRINT : PRINT : COLOR 11
PRINT "     Proceed with the modifications"
PRINT
PRINT "     Bail out... do not modify anything"
210 REM arrow
COLOR 12: LOCATE 6 + arrow2 * 2, 3
PRINT CHR$(196); CHR$(26)
220 REM get input
GOSUB 1000
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND (k1 = 27 OR k1 = 81) GOTO 260: REM esc/q
IF k2 = 1 AND (k1 = 75 OR k1 = 72) THEN GOTO 230: REM left/up
IF k2 = 1 AND (k1 = 77 OR k1 = 80) THEN GOTO 230: REM right/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 230: REM pgup/pgdn
IF k2 = 0 AND k1 = 13 GOTO 240: REM enter
GOTO 220
230 REM arrow movement
LOCATE 6 + arrow2 * 2, 3
PRINT "  "
IF k1 = 72 OR k1 = 75 THEN arrow2 = arrow2 - 1
IF k1 = 80 OR k1 = 77 THEN arrow2 = arrow2 + 1
IF k1 = 73 THEN arrow2 = 1
IF k1 = 81 THEN arrow2 = 0
IF arrow2 = 0 THEN arrow2 = 2
IF arrow2 = 3 THEN arrow2 = 1
SOUND 10000, .1
GOTO 210
240 REM enter
IF arrow2 = 1 GOTO 250
IF arrow2 = 2 GOTO 260

250 REM copy temporary files
IF scope$ = "sub" THEN
 SHELL "copy /y " + subfile2$ + " " + subfile$
END IF
IF scope$ = "sec" THEN
 FOR a = 1 TO 16
  subfile$ = mapdir$ + subsec$(2, a)
  subfile2$ = "tmp-" + LCASE$(CHR$(a + 64)) + ".tmp"
  SHELL "copy /y " + subfile2$ + " " + subfile$
 NEXT a
END IF

260 REM delete temporary files
SHELL "del tmplog.tmp"
IF scope$ = "sub" THEN
 SHELL "del " + subfile2$
END IF
IF scope$ = "sec" THEN
 FOR a = 1 TO 16
  subfile2$ = "tmp-" + LCASE$(CHR$(a + 64)) + ".tmp"
  SHELL "del " + subfile2$
 NEXT a
END IF

GOTO 10000

300 REM transform subsector file
OPEN "i", 2, subfile$
OPEN "o", 3, subfile2$
PRINT #1, "Checking "; subfile$; "..."
PRINT #1, ""
DO UNTIL EOF(2)
 REM determine weather or not each line represents a world
 world = 1
 LINE INPUT #2, t$
 IF t$ = "" THEN world = 0
 IF t$ <> "" THEN
  b$ = LEFT$(t$, 1)
  IF b$ = "@" OR b$ = "#" OR b$ = "$" THEN world = 0
 END IF
 IF LEN(t$) >= 20 THEN
  IF MID$(t$, 20, 1) = "*" THEN world = 0
 END IF
 REM if world=1 then t$ is a world
 IF world = 0 THEN PRINT #3, t$
 IF world = 0 GOTO 350
 world$ = t$
 REM read the trade codes
 trade$ = RTRIM$(MID$(world$, 33, 15))
 REM determine what the trade codes should be
 GOSUB 2000: REM trade calculator (returns s1$)
 REM compare
 IF trade$ = s1$ THEN change = 0
 IF trade$ <> s1$ THEN change = 1
 REM create world2$ (as the revised world$) if necessary
 IF change = 1 THEN
  l = LEN(s1$)
  world2$ = LEFT$(world$, 32)
  IF l <= 15 THEN world2$ = world2$ + s1$ + SPACE$(15 - l)
  IF l > 15 THEN world2$ = world2$ + LEFT$(s1$, 15)
  world2$ = world2$ + RIGHT$(world$, LEN(world$) - 47)
 END IF
 REM write entry to log file if necessary
 IF change = 1 THEN
  PRINT #1, world$
  PRINT #1, "will become:"
  PRINT #1, world2$
  PRINT #1, ""
 END IF
 REM write line to updated subsector file (temporary)
 IF change = 0 THEN PRINT #3, world$
 IF change = 1 THEN PRINT #3, world2$
350 LOOP
CLOSE 2
CLOSE 3
RETURN

1000 REM read keyboard
k1 = 0: k2 = 0
1002 k$ = INKEY$
IF k$ = "" GOTO 1002
k1 = ASC(k$)
IF k1 <> 0 GOTO 1004
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
1004 RETURN

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

5500 REM egacolor gold on blue
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

5800 REM read in sector file (subsector names & filenames)
OPEN "i", 1, secfile$
LINE INPUT #1, secname$
LINE INPUT #1, t$
FOR a = 1 TO 16
 LINE INPUT #1, t$
 subsec$(1, a) = RTRIM$(MID$(t$, 4, 26)): REM subsector name
 subsec$(2, a) = RTRIM$(RIGHT$(t$, LEN(t$) - 29)): REM filename
 l = LEN(subsec$(2, a))
 IF l > 12 THEN subsec$(2, a) = RTRIM$(LEFT$(subsec$(2, a), 12))
NEXT a
CLOSE 1
RETURN

5850 REM read trade classification codes
FOR a = 1 TO 15
   READ tccode$(a)
NEXT a
RETURN

REM trade classification data
DATA "Ag","As","Ba","De","Fl","Hi","Ic","In"
DATA "Lo","Na","Ni","Po","Ri","Va","Wa"

10000 REM end
COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email: jimv@empirenet.com"
PRINT "            jimvassila@aol.com"
END

