
REM Insert/Delete Star System v1.00
REM Public Domain 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com

REM Usage = insdel (ins) <parsec> <subsector file>
REM Usage = insdel (del) <parsec> <subsector file>

DIM w$(80)
DIM header$(3)
DIM ac$(15)
DIM ad$(15)
DIM acol(15)
DIM sptab(5, 12)
DIM tccode$(15)
DIM gastab(12)
DIM uwp$(11)
DIM tc(15)
DIM popatm(15)
DIM excode$(33)
DIM extech(33)
DIM exetc$(33)
DIM civ$(5)
DIM method$(3)
DIM namefile$(2, 10)
DIM arrow(4): DIM max(4)
arrow(1) = 5: arrow(2) = 1: arrow(3) = 1: arrow(4) = 1
max(1) = 7: max(2) = 5: max(3) = 3: max(4) = 10

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
c$ = COMMAND$
IF c$ = "" THEN
10 CLS : COLOR 12
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 2060
GOTO 10000
END IF

IF LEN(c$) < 13 GOTO 10
c1$ = MID$(c$, 2, 3)
coord$ = MID$(c$, 7, 4)
f$ = LCASE$(RIGHT$(c$, LEN(c$) - 11))

REM at this point...
REM c1$ = ins or del
REM coord$ = coordinates
REM f$ = subsector file path

IF c1$ = "DEL" THEN
   s$ = ""
   OPEN "i", 1, f$
   OPEN "o", 2, "data\subsec.tmp"
   DO UNTIL EOF(1)
      LINE INPUT #1, t$
      coord2$ = MID$(t$, 15, 4)
      IF coord$ <> coord2$ THEN PRINT #2, t$
   LOOP
   CLOSE 1
   CLOSE 2
   SHELL "del " + f$
   SHELL "copy data\subsec.tmp " + f$
   SHELL "del data\subsec.tmp"
   GOTO 10000
END IF
IF c1$ <> "INS" GOTO 10

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
REM read civ data
FOR a = 1 TO 5
   READ civ$(a)
NEXT a
REM read method data
FOR a = 1 TO 3
   READ method$(a)
NEXT a
REM read names files data
FOR a = 1 TO 2
   FOR b = 1 TO 10
      READ namefile$(a, b)
   NEXT b
NEXT a
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
REM read current settings
OPEN "i", 1, "data\insdel.dat"
LINE INPUT #1, civs$
   FOR a = 1 TO max(2)
   IF civs$ = civ$(a) THEN arrow(2) = a
   NEXT a
LINE INPUT #1, methods$
   FOR a = 1 TO max(3)
   IF methods$ = method$(a) THEN arrow(3) = a
   NEXT a
LINE INPUT #1, namesd$
   FOR a = 1 TO max(4)
   IF namesd$ = namefile$(1, a) THEN arrow(4) = a
   NEXT a
LINE INPUT #1, alleg$
CLOSE 1

20 REM intro screen
CLS : COLOR 14: p = 1
PRINT "World Insertion Menu:"
COLOR 11: PRINT
PRINT "     Civilization Level of Subsector: "; civs$
PRINT "     Method of Mainworld Generation:  "; methods$
PRINT "     Names file currently in use:     "; namesd$
PRINT "     World Allegiance Code:           "; alleg$
PRINT "     Generate World"
PRINT "     Generate Non-World"
PRINT "     Exit w/o Generating Anything"
LOCATE arrow(p) + 2, 2: COLOR 12: PRINT CHR$(196) + CHR$(26);
22 GOSUB 2060
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND (k1 = 27 OR k1 = 81) GOTO 80: REM esc/q
GOSUB 3000
IF k2 = 0 AND k1 = 13 GOTO 24: REM enter
GOTO 22
24 REM enter
IF arrow(p) = 1 GOTO 30
IF arrow(p) = 2 GOTO 40
IF arrow(p) = 3 GOTO 50
IF arrow(p) = 4 GOTO 60
IF arrow(p) = 5 GOTO 70
IF arrow(p) = 6 GOTO 4000
IF arrow(p) = 7 GOTO 80
GOTO 22

30 REM civs$
CLS : COLOR 14: p = 2
PRINT "Subsector's civilization level:"
GOSUB 3100: REM write menu
32 GOSUB 2060
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND (k1 = 27 OR k1 = 81 OR k1 = 13) GOTO 34: REM esc/q/enter
GOSUB 3000
GOTO 32
34 REM enter
civs$ = civ$(arrow(p))
GOTO 20

40 REM methods$
CLS : COLOR 14: p = 3
PRINT "Subsector's civilization level:"
GOSUB 3100: REM write menu
42 GOSUB 2060
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND (k1 = 27 OR k1 = 81 OR k1 = 13) GOTO 44: REM esc/q/enter
GOSUB 3000
GOTO 42
44 REM enter
IF arrow(p) < 3 THEN methods$ = method$(arrow(p))
IF arrow(p) = 3 AND k1 = 13 GOTO 46
IF arrow(p) = 3 AND k1 <> 13 THEN
   IF methods$ = "Official" THEN arrow(p) = 1
   IF methods$ = "Variant" THEN arrow(p) = 2
END IF
GOTO 20
46 REM read homebrew help files
SHELL "xtra\eg help\homebrew\homebrew.mnu " + reader$
SCREEN 12: SCREEN 0: CLS : GOTO 40

50 REM names$
CLS : COLOR 14: p = 4
PRINT "Type of Name:"
GOSUB 3100: REM write menu
LOCATE 15, 1: COLOR 11
PRINT "S = Scramble Name File"
52 GOSUB 2060
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND (k1 = 27 OR k1 = 81 OR k1 = 13) GOTO 54: REM esc/q/enter
IF k2 = 0 AND k1 = 83 GOTO 56: REM S
GOSUB 3000
GOTO 52
54 REM enter
namesd$ = namefile$(1, arrow(p))
GOTO 20
56 REM Scamble
IF arrow(p) = 1 GOTO 52
namesf$ = namefile$(2, arrow(p))
namesdat$ = "data\names\" + namesf$ + ".dat"
exist = 1
GOSUB 3300: REM does names file exist?
IF exist = 0 GOTO 50
LOCATE 17, 1: COLOR 14: PRINT "Scambling "; namesf$; ".dat"
SHELL "call data\names\mixname2.bat " + namesdat$ + " " + namesdat$
GOTO 50

60 REM alleg$
LOCATE 12, 1: PRINT SPACE$(70)
LOCATE 12, 1: COLOR 10
INPUT "Enter the two-letter allegiance code: ", alleg$
IF LEN(alleg$) <> 2 GOTO 60
GOTO 20

70 REM continue with generation
GOSUB 1610: REM save settings
GOSUB 1600: REM convert settings
GOTO 100

80 REM quit generation
GOSUB 1610: REM save settings
GOTO 10000

100 REM here we go...
CLS : COLOR 11: PRINT
PRINT "Generating World... (please be patient)": PRINT

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

GOSUB 3400: REM uwp coding
GOSUB 3500: REM assemble world$
GOSUB 3600: REM insert world$ into subsector file
GOTO 10000: REM end

500 REM names
namesf$ = namefile$(2, arrow(4))
IF arrow(4) = 1 THEN worname$ = coord$
IF arrow(4) = 1 THEN RETURN
namesdat$ = "data\names\" + namesf$ + ".dat"
namestmp$ = "tmpnames"
exist = 1
GOSUB 3300: REM does names file exist?
IF exist = 0 GOTO 50
SHELL "copy " + namesdat$ + " " + namestmp$
SHELL "del " + namesdat$
OPEN "i", 1, namestmp$
OPEN "o", 2, namesdat$
LINE INPUT #1, worname$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   PRINT #2, t$
LOOP
CLOSE 1
CLOSE 2
SHELL "del " + namestmp$
RETURN

600 REM starport
sport = sptab(civ, fndice(2, 6, 0))
RETURN

625 REM starport (variant)
sport = sptab(civ, fndice(2, 6, 0))
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
IF civ = 1 THEN popul = 0
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
IF civ = 1 THEN popul = 0
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
IF civ = 1 THEN popmult = 0
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

1600 REM convert settings
IF civs$ = "Unexplored" THEN civ = 1
IF civs$ = "Backwater" THEN civ = 2
IF civs$ = "Standard" THEN civ = 3
IF civs$ = "Mature" THEN civ = 4
IF civs$ = "Economic Hub" THEN civ = 5
IF methods$ = "Official" THEN method = 1
IF methods$ = "Variant" THEN method = 2
RETURN

1610 REM write current settings
OPEN "o", 1, "data\insdel.dat"
PRINT #1, civs$
PRINT #1, methods$
PRINT #1, namesd$
PRINT #1, alleg$
CLOSE 1
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

3000 REM standard arrow movement
COLOR 12
IF k2 = 1 AND (k1 = 75 OR k1 = 72) THEN GOSUB 3010: REM left/up
IF k2 = 1 AND (k1 = 77 OR k1 = 80) THEN GOSUB 3020: REM right/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) THEN GOSUB 3030: REM pgup/pgdn
RETURN
3010 REM left/up
GOSUB 3040: REM erase old arrow
arrow(p) = arrow(p) - 1
IF arrow(p) = 0 THEN arrow(p) = max(p)
GOSUB 3050: REM draw new arrow
RETURN
3020 REM right/down
GOSUB 3040: REM erase old arrow
arrow(p) = arrow(p) + 1
IF arrow(p) = max(p) + 1 THEN arrow(p) = 1
GOSUB 3050: REM draw new arrow
RETURN
3030 REM pgup/pgdn
GOSUB 3040: REM erase old arrow
IF k1 = 73 THEN arrow(p) = 1
IF k1 = 81 THEN arrow(p) = max(p)
GOSUB 3050: REM draw new arrow
RETURN
3040 REM erase arrow
LOCATE arrow(p) + 2, 2: PRINT "  ";
RETURN
3050 REM draw arrow
LOCATE arrow(p) + 2, 2: PRINT CHR$(196) + CHR$(26);
RETURN

3100 REM draw submenu
PRINT : COLOR 10
FOR a = 1 TO max(p)
PRINT "    ";
IF p = 2 THEN PRINT civ$(a)
IF p = 3 THEN PRINT method$(a)
IF p = 4 THEN PRINT namefile$(1, a)
NEXT a
LOCATE arrow(p) + 2, 2: COLOR 12: PRINT CHR$(196) + CHR$(26);
RETURN

3200 REM header
header$(1) = "#--------1---------2---------3---------4"
header$(1) = header$(1) + "---------5---------6---"
header$(2) = "#PlanetName   Loc. UPP Code   B   Notes "
header$(2) = header$(2) + "        Z  PBG Al LRX *"
header$(3) = "#----------   ---- ---------  - --------"
header$(3) = header$(3) + "------- -  --- -- --- -"
RETURN

3300 REM does names file exist?
OPEN "r", 1, namesdat$
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN
   CLS : COLOR 12: PRINT
   PRINT "The names file you selected no longer exists."
   PRINT "Please examine the contents of data\names and"
   PRINT "data\names\old, particularly the readme files,"
   PRINT "to find out why. If you need help restoring the"
   PRINT namesf$ + ".dat file to it's original state, email me"
   PRINT "for assistance. In the meantime, you can just"
   PRINT "select a different names file."
   PRINT
   GOSUB 2060
END IF
RETURN

3400 REM uwp coding
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
RETURN

3500 REM assemble world$
GOSUB 500: REM get worname$
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
world$ = world$ + " " + alleg$
IF method = 2 THEN
   world$ = world$ + " "
   FOR i = 9 TO 11
      world$ = world$ + uwp$(i)
   NEXT i
END IF
RETURN

3600 REM insert world$ into subsector file
SHELL "copy " + f$ + " subsec.tmp"
SHELL "del " + f$
REM get past jump routes and other muck
GOSUB 3200: REM get header$(3)
tmp$ = ""
OPEN "i", 1, "subsec.tmp"
OPEN "o", 2, f$
DO UNTIL tmp$ = header$(3) OR EOF(1)
   LINE INPUT #1, tmp$
   PRINT #2, tmp$
LOOP
REM read worlds
count = 0
DO UNTIL EOF(1)
   LINE INPUT #1, tmp$
   IF LEN(tmp$) > 17 THEN
      count = count + 1
      w$(count) = tmp$
   END IF
LOOP
REM add new world
count = count + 1
w$(count) = world$
REM sort worlds
IF count > 1 THEN
   FOR a = 1 TO count - 1
      FOR b = a TO count
         IF MID$(w$(a), 15, 4) > MID$(w$(b), 15, 4) THEN
            SWAP w$(a), w$(b)
         END IF
      NEXT b
   NEXT a
END IF
REM output worlds
FOR a = 1 TO count
   PRINT #2, w$(a)
NEXT a
CLOSE 1
CLOSE 2
SHELL "del subsec.tmp"
RETURN

3900 REM non-world questionnaire
CLS : COLOR 14
PRINT "Non-World Questionnaire"
PRINT : COLOR 11
PRINT "Name: "; nw$(1)
PRINT "      -------------"
PRINT : COLOR 10
PRINT "   (Put a period '.' if you want it to be unnamed)"
PRINT : COLOR 11
PRINT "Type: "; nw$(2)
PRINT "      -------------------------"
PRINT : COLOR 10
PRINT "   (Examples: Black Hole, Neutron Star, Rogue Planet,"
PRINT "   Research Station, Refueling Station, Derelict Ship,"
PRINT "   Gaseous Nebula, etc... leaving it blank is okay too)"
PRINT : COLOR 11
PRINT "Marker: "; nw$(3)
PRINT : COLOR 10
PRINT "   (1=Triangle, 2=Square, 3=Diamond, 4=Lots-o-Dots)"
PRINT : COLOR 11
PRINT "Travel Zone: "; nw$(4)
PRINT : COLOR 10
PRINT "   (A=Amber, B=Blue, G=Green, R=Red)"
RETURN

4000 REM non-world questionnaire input
FOR a = 1 TO 4
   nw$(a) = ""
NEXT a
COLOR 10: PRINT "."
4010 nw$(1) = "": GOSUB 3900
LOCATE 3, 7: INPUT "", nw$(1)
l = LEN(nw$(1))
IF l = 0 OR l > 13 GOTO 4010
4020 nw$(2) = "": GOSUB 3900
LOCATE 8, 7: INPUT "", nw$(2)
l = LEN(nw$(2))
IF l > 25 GOTO 4020
4030 nw$(3) = "": GOSUB 3900
LOCATE 15, 9: COLOR 26: PRINT "_"
4032 GOSUB 2060
IF k2 = 0 AND k1 >= 49 AND k1 <= 52 GOTO 4034
GOTO 4032
4034 nw$(3) = CHR$(k1)
4040 nw$(4) = "": GOSUB 3900
LOCATE 19, 14: COLOR 26: PRINT "_"
4042 GOSUB 2060
IF k2 = 1 GOTO 4042
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 65 OR k1 = 66 OR k1 = 71 OR k1 = 82 GOTO 4044
GOTO 4042
4044 nw$(4) = CHR$(k1): GOSUB 3900
IF nw$(4) = "G" THEN nw$(4) = " "
LOCATE 23, 1: COLOR 14
PRINT "Sure you really want to do this? (y/n) ";
GOSUB 9000
IF yn$ = "n" GOTO 20
nw$(1) = nw$(1) + SPACE$(14 - LEN(nw$(1)))
nw$(2) = nw$(2) + SPACE$(26 - LEN(nw$(2)))
world$ = nw$(1) + coord$ + " *" + nw$(3) + " " + nw$(2) + nw$(4)
world$ = world$ + SPACE$(6) + alleg$
GOSUB 3600: REM insert world$ into subsector file
GOSUB 1610
GOTO 10000

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
REM civ menu data
DATA "Unexplored","Backwater","Standard"
DATA "Mature","Economic Hub"
REM method menu data
DATA "Official","Variant"
DATA "What's the Difference?"
REM names choice data
DATA "Numeric Designation","Aslan","Darrian"
DATA "Droyne","K'kree","Solomani"
DATA "Vargr-G","Vargr-V"
DATA "Vilani","Zhodani"
REM names file data
DATA "0","aslan","darrian"
DATA "droyne","kkree","solomani"
DATA "vargr-g","vargr-v"
DATA "vilani","zhodani"

10000 REM
COLOR 7: CLS
PRINT "Later..."
END

