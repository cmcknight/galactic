
REM Sector Generation Program v1.4
REM Public Domain 1997 Jim Vassilakos
REM jimv@empirenet.com
REM jimvassila@aol.com

DIM subname$(16)
DIM subfile$(16)
DIM sod(16)
DIM civ(16)
DIM ac$(15)
DIM ad$(15)
DIM acol(15)
DIM subalg$(16)
DIM sptab(5, 12)
DIM tccode$(15)
DIM gastab(12)
DIM uwp$(11)
DIM tc(15)
DIM popatm(15)
DIM excode$(33)
DIM extech(33)
DIM exetc$(33)
DIM parsec%(1280, 2)
DIM jroute(5, 5, 4)
DIM jump%(2000, 2)
DIM namefile$(2, 9)

RANDOMIZE INT(TIMER / 2)

DEF fndie (x) = INT(RND * x) + 1
DEF fndice (x, y, z)
REM x=dice, y=sides, z=modifier
ftot = 0
FOR fa = 1 TO x
ftot = ftot + INT(RND * y) + 1
NEXT fa
fndice = ftot + z
END DEF
DEF FNxstr$ (f1) = LTRIM$(STR$(f1))
DEF FNtrans$ (f2)
   IF f2 <= 9 THEN f3$ = LTRIM$(STR$(f2))
   IF f2 >= 10 THEN f3$ = CHR$(f2 + 55)
   FNtrans$ = f3$
END DEF

SCREEN 0

IF COMMAND$ <> "000" THEN
CLS : COLOR 12
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from galcfg.exe, and only"
PRINT "after sector generation setup file has been prepared."
PRINT
PRINT "Hit any key to Exit"
GOSUB 2060
GOTO 10000
END IF

REM read starport table
FOR a = 1 TO 5
   FOR b = 2 TO 12
      READ sptab(a, b)
   NEXT b
NEXT a
REM read trade classification codes
FOR a = 1 TO 15
   READ tccode$(a)
NEXT a
REM read gas giant table
FOR a = 2 TO 12
   READ gastab(a)
NEXT a
REM read variant pop mod based on atm
FOR a = 0 TO 15
   READ popatm(a)
NEXT a
REM read names files data
FOR a = 1 TO 2
   FOR b = 1 TO 9
      READ namefile$(a, b)
   NEXT b
NEXT a

REM get editor$ & reader$
OPEN "i", 1, "gal.cfg"
LINE INPUT #1, t$: REM editor
editor$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$: REM reader
reader$ = RIGHT$(t$, LEN(t$) - 7)
CLOSE 1

REM read export code data
OPEN "i", 1, "data\export.dat"
FOR a = 1 TO 4
   LINE INPUT #1, t$
NEXT a
FOR a = 1 TO 33
   LINE INPUT #1, t$
   excode$(a) = MID$(t$, 6, 1)
   u$ = MID$(t$, 31, 1)
   IF ASC(u$) < 58 THEN extech(a) = VAL(u$)
   IF ASC(u$) > 64 THEN extech(a) = ASC(u$) - 55
   exetc$(a) = RIGHT$(t$, 1)
NEXT a
CLOSE 1

REM read sector setup file
OPEN "i", 1, "data\secgen.dat"
LINE INPUT #1, t$
sector$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$
gal0$ = RIGHT$(t$, LEN(t$) - 7)
galdir$ = "gals\" + gal0$
seclist$ = galdir$ + "\" + gal0$ + ".lst"
LINE INPUT #1, t$
secdir$ = RIGHT$(t$, LEN(t$) - 7)
FOR a = 1 TO 3
   LINE INPUT #1, t$
NEXT a
FOR a = 1 TO 16
   LINE INPUT #1, t$
   subname$(a) = RTRIM$(MID$(t$, 4, 27))
   subfile$(a) = RTRIM$(MID$(t$, 31, 8))
   sod(a) = VAL(MID$(t$, 41, 2))
   s$ = MID$(t$, 46, 1)
    IF s$ = "u" OR s$ = "U" THEN civ(a) = 1
    IF s$ = "b" OR s$ = "B" THEN civ(a) = 2
    IF s$ = "s" OR s$ = "S" THEN civ(a) = 3
    IF s$ = "m" OR s$ = "M" THEN civ(a) = 4
    IF s$ = "c" OR s$ = "C" THEN civ(a) = 5
   subalg$(a) = MID$(t$, 49, 2)
NEXT a
FOR a = 1 TO 3
   LINE INPUT #1, t$
NEXT a
a = 0
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LEN(t$) = 0 GOTO 50
   IF LEFT$(t$, 1) = "#" GOTO 50
   a = a + 1
   ac$(a) = LEFT$(t$, 2)
   ad$(a) = RTRIM$(MID$(t$, 5, 24))
   acol(a) = VAL(MID$(t$, 29, LEN(t$) - 28))
50 LOOP
numac = a
CLOSE 1

100 REM
CLS : COLOR 14
PRINT "Sector Generation Method"
PRINT
COLOR 11
PRINT "So far, this program handles two different methods for"
PRINT "mainworld generation. The first is the basic method used"
PRINT "in CT, MT, & TNE. The second is a homebrew method which"
PRINT "some people may prefer and others might not."
PRINT
120 REM
COLOR 14
PRINT "At this point, you have four options:"
PRINT : COLOR 10
PRINT "(1) Generate sector using official method"
PRINT "(2) Generate sector using homebrew method"
PRINT "(3) Read about the differences"
PRINT "(4) Quit w/o generating sector"
PRINT
125 GOSUB 2060
IF k2 = 0 AND k1 = 49 GOTO 200: REM 1
IF k2 = 0 AND k1 = 50 GOTO 200: REM 2
IF k2 = 0 AND k1 = 51 GOTO 150: REM 3
IF k2 = 0 AND k1 = 52 GOTO 10000: REM 4
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND (k1 = 81 OR k1 = 113) GOTO 10000: REM Q/q
GOTO 125

150 REM read homebrew help files
SHELL "xtra\eg help\homebrew\homebrew.mnu " + reader$
SCREEN 12: SCREEN 0: CLS : GOTO 100

200 REM begin generating sector
method = k1 - 48
CLS
COLOR 11
GOSUB 3000: REM sector setup
REM go through 16 subsectors for the sector
FOR horiz = 1 TO 4
FOR vert = 1 TO 4
REM calculate the base (upper-left) coordinates
hbase = ((horiz - 1) * 8) + 1
vbase = ((vert - 1) * 10) + 1
REM calculate the subsector number
ssnum = ((vert - 1) * 4) + horiz
sslet$ = CHR$(ssnum + 64)
REM begin subsector file
PRINT "Creating "; subname$(ssnum)
subpath$ = galdir$ + "\" + secdir$
subpath$ = subpath$ + "\map\" + subfile$(ssnum) + ".tmp"
OPEN "o", 1, subpath$
PRINT #1, "@SUB-SECTOR: "; subname$(ssnum);
PRINT #1, " SECTOR: "; sector$
PRINT #1, "#"
PRINT #1, "#--------1---------2---------3---------4";
PRINT #1, "---------5---------6---"
PRINT #1, "#PlanetName   Loc. UPP Code   B   Notes ";
PRINT #1, "        Z  PBG Al LRX *"
PRINT #1, "#----------   ---- ---------  - --------";
PRINT #1, "------- -  --- -- --- -"

REM go through 80 parsecs for the subsector
stars = 0
FOR hlocal = 1 TO 8
FOR vlocal = 1 TO 10

REM is there a star present?
IF fndie(100) > sod(ssnum) THEN GOTO 500
REM if you got this far, then yes it is present
stars = stars + 1: startot = startot + 1
worname$ = sslet$ + "-" + FNxstr$(stars)

REM calculate coordinates
vcoord = vbase + vlocal - 1
hcoord = hbase + hlocal - 1
REM make a coord string
coord$ = ""
IF hcoord < 10 THEN coord$ = "0"
coord$ = coord$ + FNxstr$(hcoord)
IF vcoord < 10 THEN coord$ = coord$ + "0"
coord$ = coord$ + FNxstr$(vcoord)

IF method = 1 THEN
   GOSUB 600: REM starport
   GOSUB 650: REM world size
   GOSUB 700: REM atmosphere
   GOSUB 750: REM hydrographics
   GOSUB 800: REM population
   GOSUB 850: REM government
   GOSUB 900: REM lawlevel
   GOSUB 950: REM technology
   GOSUB 1000: REM bases
   GOSUB 1050: REM trade classifications
   GOSUB 1100: REM population multiplier
   GOSUB 1150: REM gas giants
   GOSUB 1200: REM planetoid belts
   GOSUB 1250: REM travel codes
END IF

IF method = 2 THEN
   GOSUB 650: REM world size
   GOSUB 700: REM atmosphere
   GOSUB 775: REM hydrographics (variant)
   GOSUB 1400: REM indigenous life
   GOSUB 1300: REM resource level
   GOSUB 825: REM population (variant)
   GOSUB 1100: REM population multiplier
   GOSUB 625: REM starport (variant)
   GOSUB 850: REM government
   GOSUB 900: REM lawlevel
   GOSUB 975: REM technology
   GOSUB 990: REM tech-depopulation
   GOSUB 1050: REM trade classifications
   GOSUB 1500: REM main export commodity
   GOSUB 1000: REM bases
   GOSUB 1150: REM gas giants
   GOSUB 1200: REM planetoid belts
   GOSUB 1250: REM travel codes
END IF

REM uwp coding
IF sport = 1 THEN uwp$(1) = "A"
IF sport = 2 THEN uwp$(1) = "B"
IF sport = 3 THEN uwp$(1) = "C"
IF sport = 4 THEN uwp$(1) = "D"
IF sport = 5 THEN uwp$(1) = "E"
IF sport = 6 THEN uwp$(1) = "X"
uwp$(2) = FNtrans$(size)
uwp$(3) = FNtrans$(atmos)
uwp$(4) = FNtrans$(hydro)
uwp$(5) = FNtrans$(popul)
uwp$(6) = FNtrans$(govern)
uwp$(7) = FNtrans$(law)
uwp$(8) = FNtrans$(tech)
IF method = 2 THEN
   uwp$(9) = FNtrans$(life)
   uwp$(10) = FNtrans$(res)
   IF export > 0 THEN uwp$(11) = excode$(export)
   IF export = 0 THEN uwp$(11) = "0"
END IF

REM output starsystem
world$ = worname$
l = LEN(world$)
FOR i = l + 2 TO 15
   world$ = world$ + " "
NEXT i
world$ = world$ + coord$ + " "
FOR i = 1 TO 7
   world$ = world$ + uwp$(i)
NEXT i
world$ = world$ + "-" + uwp$(8) + "  "
world$ = world$ + base$ + " "
world$ = world$ + trade$
l = LEN(world$)
FOR i = l + 2 TO 49
   world$ = world$ + " "
NEXT i
world$ = world$ + trav$ + "  "
world$ = world$ + FNxstr$(popmult)
world$ = world$ + FNxstr$(pb)
world$ = world$ + FNxstr$(gg)
world$ = world$ + " " + subalg$(horiz + ((vert - 1) * 4))
IF method = 2 THEN
   world$ = world$ + " "
   FOR i = 9 TO 11
      world$ = world$ + uwp$(i)
   NEXT i
END IF
PRINT #1, world$

parsec%(startot, 1) = VAL(coord$)
parsec%(startot, 2) = sport

500 REM done
NEXT vlocal
NEXT hlocal
CLOSE #1
NEXT vert
NEXT horiz

510 REM
CLS : COLOR 14
PRINT "Jump Routes"
PRINT : COLOR 11
PRINT "Your sector has been generated, however, there are still"
PRINT "a few more things we could add to it. Jump routes, for"
PRINT "instance. They can be automatically generated if you like."
PRINT "The 'official' table for generating jump routes is a bit"
PRINT "funky, so an alternate 'homebrew' table has been devised."
PRINT "You can also create your own 'personal' table. Keep in"
PRINT "mind that generating jump routes, regardless of which"
PRINT "table you use, is rather cpu-intensive and may take a"
PRINT "while depending on the speed of your computer. Further,"
PRINT "you will never get as good results with automatically"
PRINT "generated jump routes as if you created them by hand."
PRINT : COLOR 10
PRINT "(1) Generate jump routes using official table"
PRINT "(2) Generate jump routes using homebrew table"
PRINT "(3) Generate jump routes using personal table"
PRINT "(4) Edit personal jump route table"
PRINT "(5) Read about the differences"
PRINT "(6) Do _not_ generate jump routes"
PRINT
520 GOSUB 2060
IF k2 = 0 AND k1 = 49 GOTO 540: REM 1
IF k2 = 0 AND k1 = 50 GOTO 540: REM 2
IF k2 = 0 AND k1 = 51 GOTO 540: REM 3
IF k2 = 0 AND k1 = 52 GOTO 530: REM 4
IF k2 = 0 AND k1 = 53 GOTO 532: REM 5
IF k2 = 0 AND k1 = 54 GOTO 535: REM 6
GOTO 520

530 REM edit personal jump route table
SHELL "sub\j3edit.exe"
GOTO 510

532 REM read homebrew jump route method
COLOR 7: CLS : PRINT "."
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
SHELL reader$ + " help\homebrew\jump.txt"
SCREEN 12: SCREEN 0: GOTO 510

535 REM no jump routes
COLOR 11: CLS
FOR a = 1 TO 16
 c$ = "copy " + galdir$ + "\" + secdir$
 c$ = c$ + "\map\" + subfile$(a) + ".tmp "
 c$ = c$ + galdir$ + "\" + secdir$
 c$ = c$ + "\map\" + subfile$(a) + ".dat"
 SHELL c$
 c$ = "erase " + galdir$ + "\" + secdir$
 c$ = c$ + "\map\" + subfile$(a) + ".tmp"
SHELL c$
NEXT a
GOTO 550

540 REM jumproutes
m = k1 - 48
FOR m1 = 1 TO 5
   FOR m2 = 1 TO 5
      FOR m3 = 1 TO 4
         jroute(m1, m2, m3) = 7
      NEXT m3
   NEXT m2
NEXT m1
OPEN "i", 1, "data\j" + CHR$(k1) + ".dat"
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   IF LEN(t$) < 39 GOTO 542
   IF MID$(t$, 2, 1) <> "-" GOTO 542
   m1 = ASC(MID$(t$, 1, 1)) - 64
   m2 = ASC(MID$(t$, 3, 1)) - 64
   m3 = VAL(MID$(t$, 12, 1))
   m4 = VAL(MID$(t$, 21, 1))
   m5 = VAL(MID$(t$, 30, 1))
   m6 = VAL(MID$(t$, 39, 1))
   IF m3 = 0 THEN m3 = 7
   IF m4 = 0 THEN m4 = 7
   IF m5 = 0 THEN m5 = 7
   IF m6 = 0 THEN m6 = 7
   jroute(m1, m2, 1) = m3
   jroute(m2, m1, 1) = m3
   jroute(m1, m2, 2) = m4
   jroute(m2, m1, 2) = m4
   jroute(m1, m2, 3) = m5
   jroute(m2, m1, 3) = m5
   jroute(m1, m2, 4) = m6
   jroute(m2, m1, 4) = m6
542 LOOP
CLOSE 1

CLS : COLOR 11
PRINT "Creating jumproutes";
nj = 0
FOR a = 1 TO startot - 1
IF a / 10 = INT(a / 10) THEN PRINT ".";
FOR b = a + 1 TO startot
  REM first hex
  c = INT(parsec%(a, 1) / 100)
  d = parsec%(a, 1) - (c * 100)
  REM second hex
  e = INT(parsec%(b, 1) / 100)
  f = parsec%(b, 1) - (e * 100)
  REM distance between
  g = ABS(c - e) + ABS(d - f)
  IF d < f THEN g = g - 1
  REM create jumproute
  ok = 1
  IF parsec%(a, 2) > 5 OR parsec%(b, 2) > 5 THEN ok = 0
  IF g = 0 OR g > 4 OR trav$ = "R" THEN ok = 0
  IF ok = 1 THEN
   IF fndie(6) >= jroute(parsec%(a, 2), parsec%(b, 2), g) THEN
    nj = nj + 1
    jump%(nj, 1) = parsec%(a, 1)
    jump%(nj, 2) = parsec%(b, 1)
   END IF
  END IF
 NEXT b
NEXT a

PRINT : PRINT "Writing jumproutes"
FOR ssnum = 1 TO 16
 PRINT "   "; subname$(ssnum)
 infile$ = galdir$ + "\" + secdir$
 infile$ = infile$ + "\map\" + subfile$(ssnum) + ".tmp"
 outfile$ = galdir$ + "\" + secdir$
 outfile$ = outfile$ + "\map\" + subfile$(ssnum) + ".dat"
 OPEN "i", 1, infile$
 OPEN "o", 2, outfile$
 LINE INPUT #1, t$
 PRINT #2, t$
 PRINT #2, "#"
 PRINT #2, "# Jump-routes"
 FOR a = 1 TO nj
  REM jump coordinates
  b = jump%(a, 1): b$ = LTRIM$(RTRIM$(STR$(b)))
  IF LEN(b$) = 3 THEN b$ = "0" + b$
  c = jump%(a, 2): c$ = LTRIM$(RTRIM$(STR$(c)))
  IF LEN(c$) = 3 THEN c$ = "0" + c$
  d = INT(b / 100): e = b - (d * 100)
  f = INT(c / 100): g = c - (f * 100)
  REM subsector corner coordinates
  h = (((ssnum - 1) MOD 4) * 8) + 1
  i = (INT((ssnum - 1) / 4) * 10) + 1
  REM are the jump points in the subsector?
  p1 = 0: REM first point in or out
  IF d >= h AND d < h + 8 AND e >= i AND e < i + 10 THEN p1 = 1
  p2 = 0: REM second point in or out
  IF f >= h AND f < h + 8 AND g >= i AND g < i + 10 THEN p2 = 1
  IF p1 = 0 AND p2 = 1 THEN
   PRINT #2, "$"; c$; " "; b$; " ";
   IF d < h THEN PRINT #2, "-1 ";
   IF d >= h AND d < h + 8 THEN PRINT #2, "0 ";
   IF d >= h + 8 THEN PRINT #2, "1 ";
   IF e < i THEN PRINT #2, "-1"
   IF e >= i AND e < i + 10 THEN PRINT #2, "0"
   IF e >= i + 10 THEN PRINT #2, "1"
  END IF
  IF p1 = 1 AND p2 = 0 THEN
   PRINT #2, "$"; b$; " "; c$; " ";
   IF f < h THEN PRINT #2, "-1 ";
   IF f >= h AND f < h + 8 THEN PRINT #2, "0 ";
   IF f >= h + 8 THEN PRINT #2, "1 ";
   IF g < i THEN PRINT #2, "-1"
   IF g >= i AND g < i + 10 THEN PRINT #2, "0"
   IF g >= i + 10 THEN PRINT #2, "1"
  END IF
  IF p1 = 1 AND p2 = 1 THEN
   PRINT #2, "$"; b$; " "; c$; " 0 0"
  END IF
 NEXT a
 DO UNTIL EOF(1)
  LINE INPUT #1, t$
  PRINT #2, t$
 LOOP
 CLOSE 1
 CLOSE 2
 c$ = "erase " + galdir$ + "\" + secdir$
 c$ = c$ + "\map\" + subfile$(ssnum) + ".tmp"
 SHELL c$
NEXT ssnum

550 REM names
CLS : COLOR 14
PRINT "World Names"
PRINT : COLOR 11
PRINT "So far, all the worlds in the sector this program just"
PRINT "generated have numeric designations. If you would like,"
PRINT "we can actually name these worlds by pulling names from"
PRINT "one of the several name files which are included with"
PRINT "this package. These name files, which are located in the"
PRINT "data\names directory, were donated by Charles Collin."
PRINT "If you would like the program to go on a wild naming"
PRINT "spree at this time, just give the word, however, also"
PRINT "keep in mind that this is a rather disk-intensive"
PRINT "process and may take awhile."
PRINT : COLOR 10
PRINT "(N)o, keep the numeric designations, and I'll do all"
PRINT "   the naming by hand later on."
PRINT
PRINT "(Y)es, go on a wild naming spree, and I'll modify the"
PRINT "   names I don't like later on."
GOSUB 9000
IF yn$ = "n" THEN GOTO 10000

560 REM choose names file
CLS : COLOR 14
PRINT "What type of world names do you want to use?"
PRINT : COLOR 11
FOR a = 1 TO 9
   PRINT "("; LTRIM$(STR$(a)); ") "; namefile$(1, a)
NEXT a
PRINT : PRINT "(Q)uit to previous screen"
565 GOSUB 2060
IF k2 = 0 AND k1 >= 49 AND k1 <= 57 GOTO 569: REM 1-9
IF k2 = 0 AND k1 = 27 GOTO 550: REM esc
IF k2 = 0 AND (k1 = 81 OR k1 = 113) GOTO 550: REM Q/q
GOTO 565
569 filenum = k1 - 48
f$ = "data\names\" + namefile$(2, filenum) + ".dat"
fo$ = "data\names\old" + namefile$(2, filenum) + ".old"

570 REM How many names are there?
names = 0
OPEN "i", 1, f$
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 names = names + 1
LOOP
CLOSE 1
IF names >= stars THEN GOTO 590
REM There aren't enough names in this file
CLS : COLOR 14: LOCATE 5
PRINT "We have a slight problem on our hands."
PRINT : COLOR 11
PRINT "Currently, there are only"; names; "in this file, and"; startot
PRINT "worlds which need naming. In other words, there aren't"
PRINT "enough names to go around. Here are your options:"
PRINT
PRINT "(1) Restore the selected names file from backup and use that"
PRINT "(2) Choose another names file to use"
PRINT "(3) Just skip the naming spree and use numeric designations"
575 GOSUB 2060
IF k2 = 0 AND k1 = 49 GOTO 580: REM 1
IF k2 = 0 AND k1 = 50 GOTO 560: REM 2
IF k2 = 0 AND k1 = 51 GOTO 10000: REM 3
GOTO 575

580 REM restore
SHELL "copy " + f0$ + " " + f$
GOTO 570

590 REM provide names for all the worlds
CLS : COLOR 11
PRINT "Step 1: Scrambling "; f$
SHELL "call data\names\mixname2.bat " + f$ + " " + f$
PRINT "Step 2: Writing Names to Subsector Files"
SHELL "copy " + f$ + " data\names.tmp"
SHELL "erase " + f$
OPEN "i", #1, "data\names.tmp"
OPEN "o", #2, f$
FOR ssnum = 1 TO 16
c$ = "copy " + galdir$ + "\" + secdir$
c$ = c$ + "\map\" + subfile$(ssnum) + ".dat "
c$ = c$ + galdir$ + "\" + secdir$
c$ = c$ + "\map\" + subfile$(ssnum) + ".tmp"
SHELL c$
c$ = "erase " + galdir$ + "\" + secdir$
c$ = c$ + "\map\" + subfile$(ssnum) + ".dat"
SHELL c$
OPEN "i", #3, galdir$ + "\" + secdir$ + "\map\" + subfile$(ssnum) + ".tmp"
OPEN "o", #4, galdir$ + "\" + secdir$ + "\map\" + subfile$(ssnum) + ".dat"
DO UNTIL MID$(t$, 63, 1) = "*"
LINE INPUT #3, t$
PRINT #4, t$
LOOP
LINE INPUT #3, t$
PRINT #4, t$
DO UNTIL EOF(3)
LINE INPUT #3, t$
LINE INPUT #1, name$
l = LEN(name$)
name$ = name$ + SPACE$(14 - l)
l = LEN(t$)
t$ = name$ + RIGHT$(t$, l - 14)
PRINT #4, t$
LOOP
CLOSE 3
CLOSE 4
c$ = "erase " + galdir$ + "\" + secdir$ + "\map\" + subfile$(ssnum) + ".tmp"
SHELL c$
NEXT ssnum
PRINT "Step 3: Dropping"; startot; " used names from "; f$
DO UNTIL EOF(1)
LINE INPUT #1, t$
PRINT #2, t$
LOOP
CLOSE 1
CLOSE 2
SHELL "erase data\names.tmp"

GOTO 10000: REM end

600 REM starport
sport = sptab(civ(ssnum), fndice(2, 6, 0))
RETURN

625 REM starport (variant)
sport = sptab(civ(ssnum), fndice(2, 6, 0))
IF popul = 0 THEN sport = 6
IF popul = 1 THEN sport = sport + 2
IF popul = 2 THEN sport = sport + 1
IF popul >= 6 AND popul <= 9 THEN sport = sport - 1
IF popul = 10 THEN sport = sport - 2
REM keeping in range
IF sport < 1 THEN sport = 1
IF sport > 6 THEN sport = 6
RETURN

650 REM world size
size = fndice(2, 6, -2)
RETURN

700 REM atmosphere
atmos = fndice(2, 6, -7) + size
IF size = 0 THEN atmos = 0
REM keeping in range
IF atmos > 15 THEN atmos = 15
IF atmos < 0 THEN atmos = 0
RETURN

750 REM hydrographics
hydro = fndice(2, 6, -7) + size
IF size <= 1 THEN hydro = 0
IF atmos <= 1 OR atmos >= 10 THEN hydro = hydro - 4
REM keeping in range
IF hydro < 0 THEN hydro = 0
IF hydro > 10 THEN hydro = 10
RETURN

775 REM hydrographics (variant)
hydro = fndice(2, 6, -7) + size
IF atmos <= 1 THEN hydro = hydro - 4
IF size <= 1 THEN hydro = 0
IF atmos >= 10 AND atmos <= 12 THEN hydro = hydro - 4
IF atmos = 14 THEN hydro = hydro - 2
REM keeping in range
IF hydro < 0 THEN hydro = 0
IF hydro > 10 THEN hydro = 10
RETURN

800 REM population
popul = fndice(2, 6, -2)
REM Unsettled
IF civ(ssnum) = 1 THEN popul = 0
RETURN

825 REM population (variant)
popul = fndice(2, 6, -2)
IF size <= 2 THEN popul = popul - 1
popul = popul + popatm(atmos)
IF hydro = 0 AND atmos > 3 THEN popul = popul - 2
IF life = 0 THEN popul = popul - 2
IF life >= 7 THEN popul = popul + 2
IF res = 0 THEN popul = popul - 3
IF res >= 1 AND res <= 4 THEN popul = popul - 1
IF res >= 5 AND res <= 8 THEN popul = popul + 1
IF res >= 9 AND res <= 12 THEN popul = popul + 2
IF res >= 13 THEN popul = popul + 3
REM keeping in range
IF popul < 0 THEN popul = 0
IF popul > 10 THEN popul = 10
REM Unsettled
IF civ(ssnum) = 1 THEN popul = 0
RETURN

850 REM government
govern = fndice(2, 6, -7) + popul
IF method = 2 THEN
   IF popul = 0 AND popmult = 0 THEN govern = 0
END IF
REM: keeping in range
IF govern < 0 THEN govern = 0
IF govern > 15 THEN govern = 15
RETURN

900 REM lawlevel
law = fndice(2, 6, -7) + govern
IF method = 2 THEN
   IF govern = 0 THEN law = 0
END IF
REM keeping in range
IF law < 0 THEN law = 0
IF law > 20 THEN law = 20
RETURN

950 REM technology
tech = fndie(6)
IF sport = 1 THEN tech = tech + 6
IF sport = 2 THEN tech = tech + 4
IF sport = 3 THEN tech = tech + 2
IF sport = 6 THEN tech = tech - 4
IF size <= 1 THEN tech = tech + 2
IF size >= 2 AND size <= 4 THEN tech = tech + 1
IF atmos <= 3 OR atmos >= 10 THEN tech = tech + 1
IF hydro = 9 THEN tech = tech + 1
IF hydro = 10 THEN tech = tech + 2
IF popul >= 1 AND popul <= 5 THEN tech = tech + 1
IF popul = 9 THEN tech = tech + 2
IF popul = 10 THEN tech = tech + 4
IF govern = 0 OR govern = 5 THEN tech = tech + 1
IF govern = 13 THEN tech = tech - 2
REM keeping in range
IF tech < 0 THEN tech = 0
RETURN

975 REM technology variant
tech = fndie(6)
REM non-standard chart
IF sport = 1 THEN tech = tech + 6
IF sport = 2 THEN tech = tech + 4
IF sport = 3 THEN tech = tech + 2
IF sport = 6 THEN tech = tech - 4
IF size <= 1 THEN tech = tech + 2
IF size >= 2 AND size <= 4 THEN tech = tech + 1
IF atmos <= 3 THEN tech = tech + 1
IF atmos >= 10 AND atmos <= 12 THEN tech = tech + 1
IF hydro = 9 THEN tech = tech + 1
IF hydro = 10 THEN tech = tech + 2
IF popul >= 1 AND popul <= 5 THEN tech = tech + 1
IF popul = 9 THEN tech = tech + 2
IF popul = 10 THEN tech = tech + 4
IF law >= 11 AND law <= 14 THEN tech = tech - 1
IF law >= 15 THEN tech = tech - 2
IF govern = 1 OR govern = 5 THEN tech = tech + 1
IF govern = 13 OR govern = 14 THEN tech = tech - 2
IF govern = 6 OR govern = 15 THEN tech = tech - 1
REM zero pop tech drop
IF popul = 0 AND popmult = 0 THEN tech = 0
REM keeping in range
IF tech < 0 THEN tech = 0
RETURN

990 REM tech depopulation
min = 0
IF ((hydro = 0 OR hydro = 10) AND popul >= 6) THEN min = 4
IF (atmos = 4 OR atmos = 7 OR atmos = 9) THEN min = 5
IF (atmos <= 3 OR (atmos >= 10 AND atmos <= 12)) THEN min = 7
IF ((atmos = 13 OR atmos = 15) AND hydro = 10) THEN min = 7
IF min > tech THEN
   popul = 0
   popmult = 0
   govern = 0
   law = 0
   tech = 0
   sport = 6
END IF
RETURN

1000 REM bases
REM naval
navy = 0
IF (sport <= 2) AND fndice(2, 6, 0) >= 8 THEN navy = 1
REM scout
scout = 0
d = fndice(2, 6, 0)
IF sport = 1 AND d >= 10 THEN scout = 1
IF sport = 2 AND d >= 9 THEN scout = 1
IF sport = 3 AND d >= 8 THEN scout = 1
IF sport = 4 AND d >= 7 THEN scout = 1
REM base code
IF navy = 0 AND scout = 0 THEN base$ = " "
IF navy = 0 AND scout = 1 THEN base$ = "S"
IF navy = 1 AND scout = 0 THEN base$ = "N"
IF navy = 1 AND scout = 1 THEN base$ = "2"
RETURN

1050 REM trade classifications
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
trade$ = ""
FOR j = 1 TO 15
   IF tc(j) = 1 THEN trade$ = trade$ + tccode$(j) + " "
NEXT j
RETURN

1100 REM population multiplier (variant & official)
popmult = fndice(1, 9, 0)
IF method = 2 THEN
   IF popul = 0 AND fndie(6) < 6 THEN popmult = 0
END IF
REM Unsettled
IF civ(ssnum) = 1 THEN popmult = 0
RETURN

1150 REM gas giants
gg = 0
IF fndice(2, 6, 0) >= 5 THEN gg = gastab(fndice(2, 6, 0))
RETURN

1200 REM planetoid belts
d1 = fndice(2, 6, 0)
d2 = fndice(2, 6, 0)
pb = 0
IF d1 >= 8 AND d2 <= 7 THEN pb = 1
IF d1 >= 8 AND d2 >= 8 THEN pb = 2
IF d1 >= 8 AND d2 = 12 THEN pb = 3
RETURN
    
1250 REM travel codes
REM roughly speaking
trav$ = " "
IF govern + law >= 30 THEN trav$ = "A"
IF govern + law >= 33 THEN trav$ = "R"
RETURN

1300 REM resources
REM roll 2d6-7+size
res = fndice(2, 6, -7) + size
REM keeping in range
IF res < 0 THEN res = 0
IF res > 15 THEN res = 15
RETURN

1400 REM life / indigenous ecosystem
REM roll d12-1 twice, take lower of two rolls
life = fndice(1, 12, -1)
tmp = fndice(1, 12, -1)
IF tmp < life THEN life = tmp
IF atmos <= 1 THEN life = 0
IF atmos >= 10 AND atmos <= 12 THEN life = life - 6
IF hydro = 0 THEN life = life - 4
IF (life = 10 OR life = 11) THEN
   IF fndie(2) = 1 THEN life = life + 2
END IF
REM keeping in range
IF life < 0 THEN life = 0
IF life > 13 THEN life = 13
REM eco-collapse
IF life = 13 THEN
   atmos = 12
   hydro = hydro - 4
   IF hydro < 0 THEN hydro = 0
END IF
RETURN

1500 REM Main Export Commodity
export = 0: best = -1
IF res >= 5 AND tech >= 1 AND popul >= 5 THEN
FOR m = 1 TO res
   IF tc(1) = 1 THEN maybe = fndie(5)
   IF tc(1) = 0 THEN maybe = fndice(1, 29, 4)
   IF tech < extech(maybe) THEN GOTO 1510
   IF exetc$(maybe) = "A" AND tc(1) = 0 THEN GOTO 1510
   IF exetc$(maybe) = "L" AND life < 7 THEN GOTO 1510
   IF extech(maybe) > best THEN
      export = maybe
      best = extech(export)
   END IF
1510 NEXT m
END IF
RETURN

2060 REM read keyboard
k1 = 0: k2 = 0
2062 k$ = INKEY$
IF k$ = "" THEN GOTO 2062
SOUND 10000, .1
k1 = ASC(k$)
IF k1 <> 13 THEN GOTO 2063
FOR note = 1 TO 10
SOUND note * 200, .1
NEXT note
2063 IF k1 <> 0 THEN GOTO 2064
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
2064 RETURN

3000 REM basic sector setup
REM directory tree
PRINT "Making subdirectories"
SHELL "mkdir " + galdir$ + "\" + secdir$
SHELL "mkdir " + galdir$ + "\" + secdir$ + "\" + "gen"
SHELL "mkdir " + galdir$ + "\" + secdir$ + "\" + "loc"
SHELL "mkdir " + galdir$ + "\" + secdir$ + "\" + "map"
SHELL "mkdir " + galdir$ + "\" + secdir$ + "\" + "hex"
SHELL "mkdir " + galdir$ + "\" + secdir$ + "\" + "sys"
REM sector file
PRINT "Writing sector overview"
OPEN "o", 1, galdir$ + "\" + secdir$ + "\" + secdir$ + ".dat"
PRINT #1, sector$
PRINT #1, ""
FOR a = 1 TO 16
   PRINT #1, CHR$(64 + a); ": "; subname$(a);
   PRINT #1, SPACE$(26 - LEN(subname$(a)));
   PRINT #1, subfile$(a); ".dat"
NEXT a
PRINT #1, ""
PRINT #1, "Bases:"
PRINT #1, "N = Navy"
PRINT #1, "S = Scout"
PRINT #1, "2 = Navy & Scout"
PRINT #1, "  = None"
PRINT #1, ""
PRINT #1, "Allegiance:"
FOR a = 1 TO numac
   t$ = LTRIM$(RTRIM$(STR$(acol(a))))
   IF acol(a) < 10 THEN t$ = "0" + t$
   PRINT #1, t$; " ";
   PRINT #1, ac$(a); " = ";
   PRINT #1, ad$(a)
NEXT a
PRINT #1, "08    = Unknown"
CLOSE 1
REM data menu
PRINT "Writing menus"
OPEN "o", 1, galdir$ + "\" + secdir$ + "\map\data.mnu"
PRINT #1, "@dir="; galdir$; "\"; secdir$; "\map"
PRINT #1, "@Light Yellow"
PRINT #1, ""
PRINT #1, sector$; " / Data Files"
PRINT #1, ""
PRINT #1, "@Light Cyan"
PRINT #1, "      Sector Data"; SPACE$(20); "@..\";
PRINT #1, secdir$; ".dat"
PRINT #1, ""
PRINT #1, "@Light Green"
PRINT #1, "      Subsector Data"
PRINT #1, "@Light Cyan"
FOR a = 1 TO 16
   PRINT #1, SPACE$(7); CHR$(64 + a); ": ";
   PRINT #1, subname$(a);
   PRINT #1, SPACE$(27 - LEN(subname$(a)));
   PRINT #1, "@"; subfile$(a); ".dat"
NEXT a
CLOSE 1
REM sector menu
OPEN "o", 1, galdir$ + "\" + secdir$ + "\gen\sector.mnu"
PRINT #1, "@dir="; galdir$; "\"; secdir$; "\gen"
PRINT #1, "@Light Yellow"
PRINT #1, ""
PRINT #1, sector$; " / General Information"
PRINT #1, ""
PRINT #1, "@Light Cyan"
PRINT #1, "      Sector Data";
PRINT #1, SPACE$(18); "@..\map\data.mnu"
CLOSE 1
REM update sector list
OPEN "i", 1, galdir$ + "\where.dat"
INPUT #1, nowatx
INPUT #1, nowaty
CLOSE 1
secline$ = secdir$ + SPACE$(13 - LEN(secdir$))
secline$ = secline$ + sector$ + SPACE$(37 - LEN(sector$))
nowatx$ = FNxstr$(nowatx)
nowatx$ = nowatx$ + SPACE$(4 - LEN(nowatx$))
nowaty$ = FNxstr$(nowaty)
nowaty$ = nowaty$ + SPACE$(4 - LEN(nowaty$))
secline$ = secline$ + nowatx$ + " " + nowaty$ + " K"
OPEN "i", 1, seclist$
OPEN "o", 2, "tmp.tmp"
LINE INPUT #1, t$
PRINT #2, t$
LINE INPUT #1, t$
PRINT #2, t$
catch = 0
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 IF RTRIM$(LEFT$(t$, 8)) = secdir$ THEN
  PRINT #2, secline$
  catch = 1
 ELSE
  PRINT #2, t$
 END IF
LOOP
IF catch = 0 THEN PRINT #2, secline$
CLOSE 1
CLOSE 2
SHELL "del " + seclist$
SHELL "copy tmp.tmp " + seclist$
SHELL "del tmp.tmp"
RETURN

9000 REM y/n
yn$ = ""
GOSUB 2060
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 78 THEN yn$ = "n": REM N
IF k2 = 0 AND k1 = 89 THEN yn$ = "y": REM Y
IF yn$ = "" GOTO 9000
RETURN

REM starport data
REM each line corresponds to one of the 5 civilization codes
REM 1's = class A... 6's = class X
REM see megatrav ref's manual, p24, left column
DATA 6,6,6,6,6,6,6,6,6,6,6: REM Unexplored
DATA 1,1,2,2,3,3,3,4,5,5,6: REM Backwater
DATA 1,1,1,2,2,3,3,4,5,5,6: REM Standard
DATA 1,1,1,2,2,3,3,4,5,5,5: REM Mature
DATA 1,1,1,1,2,2,3,3,4,5,6: REM Economic Hub
REM trade classification data
DATA "Ag","As","Ba","De","Fl","Hi","Ic","In"
DATA "Lo","Na","Ni","Po","Ri","Va","Wa"
REM gas giant data
DATA 1,1,2,2,3,3,4,4,4,5,5
REM pop-atmos modifers
DATA -3,-3,-3,-3,0,1,3,0,1,0,-2,-3,-4,-2,-2,-2
REM names choice data
DATA "Aslan","Darrian"
DATA "Droyne","K'kree","Solomani"
DATA "Vargr-G","Vargr-V"
DATA "Vilani","Zhodani"
REM names file data
DATA "aslan","darrian"
DATA "droyne","kkree","solomani"
DATA "vargr-g","vargr-v"
DATA "vilani","zhodani"

10000 REM
COLOR 7: CLS
PRINT "Later..."
END

