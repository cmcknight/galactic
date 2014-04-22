
REM Star System Map v1.1(g)
REM Public Domain 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com
REM Written in Microsoft QuickBasic version 4.5
REM Includes SAVESCR v0.6 by Aaron Zabudsky <zabudsk@ecf.utoronto.ca>
REM
REM Usage = sysmap <filename> <system name> <(stars)>
REM
REM Examples:
REM   sysmap
REM   sysmap example
REM   sysmap example Alpha Aplos
REM   sysmap example Alpha Aplos (F5 G5 / M5)

DECLARE SUB savescr (filename$, sx!, sy!, ex!, ey!, nbits!, imgnum!)

DIM letimage(13, 44) AS INTEGER
DIM length(44)
DIM colors$(15)
DIM stardes$(60)
DIM starshar(60)
DIM starmass(60)
DIM starpl$(60)
DIM star1st(60)
DIM starbio(60)
DIM starcol(60)
DIM starsiz(60)
DIM plcode$(30)
DIM plsize(30)
DIM plcolor(30)
DIM pldes$(30)
DIM plsin(30)
DIM plsbio(30)
DIM plsout(30)
DIM plmoon$(30)
DIM numstar(2)
DIM numpl(2)
DIM starpos$(3)
DIM scol(2, 3)
DIM ssiz(2, 3)
DIM starname$(2, 3)
DIM scomment$(2, 3)
DIM sattach$(2, 3)
DIM porbit(2, 30)
DIM porbcol(2, 30)
DIM pcol(2, 30)
DIM psiz(2, 30)
DIM pex(2, 30)
DIM pey(2, 30)
DIM pdeg(2, 30)
DIM pmoons(2, 30)
DIM pname$(2, 30)
DIM pcomment$(2, 30)
DIM pattach$(2, 30)
DIM spos(4)
DIM ppos(21)
DIM syst(5)
DIM prob(60)
DIM weight(3, 2)
DIM stc(2, 5): REM stars (by # in stars.dat) on command line
DIM stcn(2): REM number of stars in stc

RANDOMIZE INT(TIMER / 2)
REM ON ERROR GOTO 5800

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

DEF FNstn (f14$)
   f15 = 0
   FOR f15b = 1 TO nstars
      IF f14$ = LEFT$(stardes$(f15b), 2) THEN f15 = f15b
   NEXT f15b
   FNstn = f15
END DEF

DEF FNroll (f1$)
   f1$ = LTRIM$(RTRIM$(f1$))
   f2 = INSTR(f1$, "d")
   f3 = INSTR(f1$, "+")
   IF INSTR(f1$, "-") > f3 THEN f3 = INSTR(f1$, "-")
   f4 = LEN(f1$)
   IF f2 = 0 THEN f9 = VAL(f1$): REM just a number
   IF f2 > 0 THEN
      IF f2 = 1 THEN
        f5 = 1
      ELSE
         f5 = VAL(LEFT$(f1$, f2 - 1)): REM n of nds+m
      END IF
      IF f3 = 0 THEN
         f6 = VAL(MID$(f1$, f2 + 1, f4 - f2)): REM s
         f7 = 0: REM m
      ELSE
         f6 = VAL(MID$(f1$, f2 + 1, f3 - f2 - 1)): REM s
         f7 = VAL(MID$(f1$, f3, f4 - f3 + 1)): REM m
      END IF
      f9 = 0
      FOR f8 = 1 TO f5
         f9 = f9 + INT(RND * f6) + 1
      NEXT f8
      f9 = f9 + f7
   END IF
   FNroll = f9
END DEF

DEF FNout (cats)
   REM must design prob(1..cats) prior to calling FNout
   REM prob(x) has highest acceptable roll for category x
   sum = prob(cats)
   dice$ = "d" + LTRIM$(STR$(sum))
   roll = FNroll(dice$)
   f2 = 0
   FOR f1 = cats TO 1 STEP -1
      IF roll <= prob(f1) THEN f2 = f1
   NEXT f1
   FNout = f2
END DEF

DEF FNorbcol (f1, f2)
   REM figure out orbit color
   biozone = 0
   FOR f3 = 1 TO nstars
      IF stardes$(f3) = scomment$(f1, 1) THEN
         biozone = starbio(f3)
         hotzone = star1st(f3)
      END IF
   NEXT f3
   f4 = porbit(f1, f2)
   IF f4 < biozone THEN f5 = 4: REM in
   IF f4 = biozone THEN f5 = 10: REM bio
   IF f4 > biozone THEN f5 = 1: REM out
   IF pcomment$(f1, f2) = "Asteroid Belt" THEN f5 = 7
   IF pex(f1, f2) <> 0 OR pey(f1, f2) <> 1 THEN f5 = 13
   IF f4 < hotzone THEN f5 = 14: REM vaporization orbit
   FNorbcol = f5
END DEF

DEF FNrmchar$ (f20$, f21)
   f22 = LEN(f20$): f23$ = "": f24$ = ""
   IF f21 > 0 AND f21 <= f22 THEN
     IF f21 > 1 THEN f23$ = LEFT$(f20$, f21 - 1)
     IF f21 < f22 THEN f24$ = RIGHT$(f20$, f22 - f21)
   END IF
   FNrmchar$ = f23$ + f24$
END DEF

REM disect command line
starc$ = ""
c$ = COMMAND$
10 IF c$ = "" THEN
   CLS : COLOR 11: LOCATE 5
   INPUT "Enter Sysmap File: ", c$
END IF
c$ = LCASE$(RTRIM$(LTRIM$(c$)))
IF c$ = "" GOTO 10005
a = INSTR(c$, "(")
IF a = 0 GOTO 15
starc$ = RIGHT$(c$, LEN(c$) - a + 1)
c$ = RTRIM$(LEFT$(c$, a - 1))
15 a = INSTR(c$, " ")
IF a <> 0 THEN
   l = LEN(c$)
   sysname$ = LTRIM$(RIGHT$(c$, l - a))
   c$ = LEFT$(c$, a - 1)
   REM capitalize sysname$
   l = LEN(sysname$)
   FOR b = 1 TO l
      m = ASC(MID$(sysname$, b, 1))
      IF m >= 97 AND m <= 122 THEN m = m - 32
      n = 0
      IF b > 1 THEN
         IF ASC(MID$(sysname$, b - 1, 1)) = 32 THEN n = 1
      END IF
      IF b = 1 THEN sysname$ = CHR$(m) + RIGHT$(sysname$, l - 1)
      IF b > 1 AND n = 1 THEN
         tmp$ = LEFT$(sysname$, b - 1) + CHR$(m)
         tmp$ = tmp$ + RIGHT$(sysname$, l - b)
         sysname$ = tmp$
      END IF
   NEXT b
END IF
IF INSTR(c$, "\") = 0 THEN
   f$ = c$
   locdir$ = ""
ELSE
   l = LEN(c$)
   FOR a = 1 TO l
      IF MID$(c$, a, 1) = "\" THEN b = a
   NEXT a
   f$ = RIGHT$(c$, l - b)
   locdir$ = LEFT$(c$, b)
END IF
IF INSTR(f$, ".") = 0 THEN
   IF LEN(f$) > 8 THEN c$ = ""
   f$ = f$ + ".sys"
END IF
IF RIGHT$(f$, 4) <> ".sys" THEN c$ = ""
IF c$ = "" GOTO 10
bmpfile$ = LEFT$(f$, LEN(f$) - 4) + ".bmp"
sysfile$ = locdir$ + f$
sysname2$ = sysname$
IF LEN(sysname2$) > 12 THEN sysname2$ = LEFT$(sysname2$, 12)

GOSUB 5600: REM initial variable settings
GOSUB 5700: REM read config info
GOSUB 5000: REM read letters.dat -> image data
GOSUB 5020: REM read stars.dat
GOSUB 5550: REM stars on command line?
GOSUB 5030: REM read planets.dat
GOSUB 5040: REM read system.dat
GOSUB 5090: REM read names of 15 colors
90 GOSUB 2000: REM load star system map

100 REM show star system
GOSUB 305: REM calc yy & baseb
GOSUB 310: REM display header
GOSUB 315: REM display hub
GOSUB 330: REM display orbits
GOSUB 340: REM display planets
GOSUB 350: REM display planet numbers
GOSUB 360: REM list planets
GOSUB 470: REM help/quit hint

290 GOSUB 370: REM draw arrow
300 GOSUB 1000
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 1 AND (k1 = 72 OR k1 = 80) GOTO 410: REM up/down
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 410: REM pgup/pgdn
IF k2 = 1 AND (k1 = 75 OR k1 = 77) GOTO 410: REM left/right
IF k2 = 0 AND (k1 = 27 OR k1 = 81) GOTO 10000: REM esc/q (save & quit)
IF k2 = 0 AND k1 = 24 GOTO 10005: REM ctrl-x (exit w/o saving)
IF k2 = 0 AND k1 = 60 GOTO 480: REM <
IF k2 = 0 AND (k1 = 63 OR k1 = 72) GOTO 460: REM ?/h
IF k2 = 0 AND k1 = 12 GOTO 100: REM ctrl-l
IF k2 = 0 AND (k1 = 49 OR k1 = 50) GOTO 490: REM 1/2 (deg)
IF k2 = 0 AND (k1 >= 51 AND k1 <= 54) GOTO 900: REM 3-6 (eccenticity)
IF k2 = 0 AND (k1 = 67 OR k1 = 79) GOTO 600: REM c/o (color)
IF k2 = 0 AND (k1 = 78 OR k1 = 68) GOTO 640: REM n/d (name/description)
IF k2 = 0 AND k1 = 77 GOTO 660: REM m (moons)
IF k2 = 0 AND k1 = 80 GOTO 680: REM p (change planet)
IF k2 = 0 AND k1 = 83 GOTO 700: REM s (change star)
IF k2 = 0 AND k1 = 65 GOTO 730: REM a (add planet)
IF k2 = 0 AND k1 = 35 GOTO 800: REM # (change orbit #)
IF k2 = 1 AND k1 = 59 GOTO 500: REM F1 (generate new system w/ same stars)
IF k2 = 1 AND k1 = 60 GOTO 500: REM F2 (generate new system w/ new stars)
IF k2 = 1 AND k1 = 68 GOTO 400: REM F10 (bitmap)
IF k2 = 1 AND k1 = 82 GOTO 420: REM insert
IF k2 = 1 AND k1 = 83 GOTO 440: REM delete
IF k2 = 0 AND (k1 = 13 OR k1 = 32 OR k1 = 62) GOTO 450: REM enter/sp/>
GOTO 300

305 REM calc yy & baseb
yy = 479 - (numpl(star) + 2) * 7
baseb = INT(yy / 2) + 20
RETURN

310 REM display header
SCREEN 12
GOSUB 6000: REM set palette
CLS : COLOR 10: PRINT sysname$
FOR b = 1 TO numstar(star)
   word$ = starpos$(b): spos(b) = b * 7 + 15
   x = 10: y = spos(b): GOSUB 5100
   word$ = sname$(star, b)
   x = 100: y = spos(b): GOSUB 5100
   word$ = scomment$(star, b)
   x = 220: y = spos(b): GOSUB 5100
   IF sattach$(star, b) <> "" THEN CIRCLE (95, spos(b) - 2), 1, 14
NEXT b
IF numsys = 2 THEN
   word$ = "Far Companion"
   spos(numstar(star) + 1) = (numstar(star) + 1) * 7 + 15
   x = 10: y = spos(numstar(star) + 1): GOSUB 5100
END IF
RETURN

315 REM display hub
SELECT CASE numstar(star)
CASE 1: REM hub solo
   tmp = 0: tmp2 = 1: GOSUB 320
CASE 2: REM hub binary
   dist = INT((ssiz(star, 1) + ssiz(star, 2)) / 2) + 3
   tmp = -dist: tmp2 = 1: GOSUB 320
   tmp = dist: tmp2 = 2: GOSUB 320
CASE 3: REM hub trinary
   tmp = 0: tmp2 = 1: GOSUB 320
   dist = ssiz(star, 1) + ssiz(star, 2) + 3
   tmp = -dist: tmp2 = 2: GOSUB 320
   dist = ssiz(star, 1) + ssiz(star, 3) + 3
   tmp = dist: tmp2 = 3: GOSUB 320
END SELECT
RETURN
320 REM draw star
IF ssiz(star, tmp2) > 0 THEN
   CIRCLE (basea + tmp, baseb), ssiz(star, tmp2), scol(star, tmp2)
   PSET (basea + tmp, baseb), 0
   PAINT (basea + tmp, baseb), scol(star, tmp2), scol(star, tmp2)
END IF
RETURN

330 REM display orbits
IF numpl(star) = 0 THEN RETURN
FOR a = 1 TO numpl(star)
a2 = (porbit(star, a) + push) ^ 1.79
x = basea + pex(star, a)
y = baseb
CIRCLE (x, y), a2, porbcol(star, a), , , .3 * pey(star, a)
NEXT a
RETURN

340 REM draw planets
IF numpl(star) = 0 THEN RETURN
FOR a = 1 TO numpl(star)
   orb = porbit(star, a)
   deg = pdeg(star, a)
   a2 = (orb + push) ^ 1.79
   r = ((-deg + 180) / 360) * pi# * 2: REM too convoluted
   sina = SIN(r) * a2 + basea + pex(star, a)
   sinb = COS(r) * a2 * .3 * pey(star, a) + baseb
   IF psiz(star, a) > 0 THEN
      CIRCLE (sina, sinb), psiz(star, a), pcol(star, a)
      PSET (sina, sinb), 0
      PAINT (sina, sinb), pcol(star, a), pcol(star, a)
   END IF
NEXT a
RETURN

350 REM draw planet numbers
IF numpl(star) = 0 THEN RETURN
FOR a = 1 TO numpl(star)
   orb = porbit(star, a)
   deg = pdeg(star, a)
   a2 = (orb + push) ^ 1.79
   r = ((-deg + 180) / 360) * pi# * 2: REM convoluted
   sina = SIN(r) * a2 + basea + pex(star, a)
   sinb = COS(r) * a2 * .3 * pey(star, a) + baseb
   x = sina + 5: y = sinb + 5: word$ = LTRIM$(STR$(orb))
   IF porbcol(star, a) <> 7 THEN GOSUB 5100: REM don't number belts
NEXT a
RETURN

360 REM list planets
IF numpl(star) = 0 THEN RETURN
FOR a = 1 TO numpl(star)
   word$ = "Orbit" + STR$(porbit(star, a))
   ppos(a) = yy + a * 7
   x = 10: y = ppos(a): GOSUB 5100
   word$ = pname$(star, a)
   x = 100: y = ppos(a): GOSUB 5100
   word$ = pcomment$(star, a)
   x = 220: y = ppos(a): GOSUB 5100
   word$ = LTRIM$(STR$(pmoons(star, a)))
   x = 400: y = ppos(a): GOSUB 5100
   IF pattach$(star, a) <> "" THEN CIRCLE (95, ppos(a) - 2), 1, 14
   IF a MOD 3 = 0 AND a <> numpl(star) THEN
      LINE (9, yy + a * 7 + 1)-(415, yy + a * 7 + 1), 4
   END IF
NEXT a
RETURN

370 REM draw arrow
arrowcol = 13
GOSUB 380
RETURN
375 REM erase arrow
arrowcol = 0
GOSUB 380
RETURN
380 REM arrow
x = 7
IF p1 = 1 THEN y = spos(p2) - 2
IF p1 = 2 THEN y = ppos(p2) - 2
LINE (x, y)-(x - 6, y), arrowcol
LINE (x, y)-(x - 2, y - 2), arrowcol
LINE (x, y)-(x - 2, y + 2), arrowcol
RETURN

400 REM save screen
savescr bmpfile$, 0, 0, 639, 479, 4, 0
SCREEN 0: CLS : LOCATE 5: COLOR 11
PRINT
PRINT "System map saved to "; bmpfile$
PRINT
PRINT "Hit any key to return to the map"
PRINT
GOSUB 1000
GOTO 100

410 REM arrows/pgup/pgdn
fc = numsys - 1
GOSUB 375
SELECT CASE k1
   CASE 73
      p1 = 1: p2 = 1
   CASE 81
      p1 = 2: p2 = numpl(star)
   CASE 72, 75
      p2 = p2 - 1
      IF p1 = 2 AND p2 = 0 THEN
         p1 = 1: p2 = numstar(star) + fc
      END IF
      IF p1 = 1 AND p2 = 0 THEN
         p1 = 2: p2 = numpl(star)
      END IF
   CASE 77, 80
      p2 = p2 + 1
         IF p1 = 1 AND p2 = numstar(star) + fc + 1 THEN
            p1 = 2: p2 = 1
         END IF
         IF p1 = 2 AND p2 = numpl(star) + 1 THEN
            p1 = 1: p2 = 1
         END IF
END SELECT
GOTO 290

420 REM insert
IF p1 = 1 THEN name$ = sname$(star, p2)
IF p1 = 2 THEN name$ = pname$(star, p2)
GOSUB 1100: REM erase status line
PRINT "Do you want to attach a ";
PRINT "(f)ile, a (m)enu, a (h)exworld, or (n)othing?"
425 GOSUB 1000
IF k2 = 1 GOTO 425
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 27 OR k1 = 81 GOTO 100: REM esc/q
IF k1 = 70 GOTO 430: REM File
IF k1 = 77 GOTO 435: REM Menu
IF k1 = 72 GOTO 426: REM Hexworld
IF k1 = 78 GOTO 100: REM Nothing
GOTO 425
426 GOSUB 1100: REM erase status line
INPUT "Enter file name (8 chars max, no extension): ", tmp$
tmp$ = RTRIM$(LTRIM$(tmp$))
IF INSTR(tmp$, ".") > 0 GOTO 426
l = LEN(tmp$)
IF l > 8 GOTO 426
IF l = 0 GOTO 420
tmp$ = tmp$ + ".hex"
SHELL "sub\hexworld " + locdir$ + tmp$ + " " + name$
GOTO 439
430 GOSUB 1100: REM erase status line
INPUT "Enter file name (8 chars max, no extension): ", tmp$
tmp$ = RTRIM$(LTRIM$(tmp$))
IF INSTR(tmp$, ".") > 0 GOTO 430
l = LEN(tmp$)
IF l > 8 GOTO 430
IF l = 0 GOTO 420
tmp$ = tmp$ + ".txt"
OPEN "r", 1, locdir$ + tmp$
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN
   OPEN "o", 1, locdir$ + tmp$
   PRINT #1, name$
   PRINT #1, STRING$(LEN(name$), "-")
   PRINT #1, ""
   PRINT #1, ""
   CLOSE 1
END IF
GOTO 438
435 GOSUB 1100: REM erase status line
INPUT "Enter menu name (8 chars max, no extension): ", tmp$
tmp$ = RTRIM$(LTRIM$(tmp$))
IF INSTR(tmp$, ".") > 0 GOTO 435
l = LEN(tmp$)
IF l > 8 GOTO 435
IF l = 0 GOTO 420
tmp$ = tmp$ + ".mnu"
name$(numplace, 2) = tmp$
OPEN "r", 1, locdir$ + tmp$
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN
   OPEN "o", 1, locdir$ + tmp$
   IF locdir$ <> "" THEN
      PRINT #1, "@dir="; LEFT$(locdir$, LEN(locdir$) - 1)
   END IF
   PRINT #1, "@Light Yellow"
   PRINT #1, ""
   PRINT #1, SPACE$(10);
   PRINT #1, name$
   PRINT #1, ""
   PRINT #1, ""
   PRINT #1, "@Light Cyan"
   PRINT #1, "     Topic #1     @topic1.txt"
   PRINT #1, "     Topic #2     @topic2.txt"
   PRINT #1, ""
   CLOSE 1
END IF
438 GOSUB 5500: REM egacolor
SHELL editor$ + " " + locdir$ + tmp$
439 IF p1 = 1 THEN sattach$(star, p2) = tmp$
IF p1 = 2 THEN pattach$(star, p2) = tmp$
GOTO 100

440 REM delete
IF p1 = 1 THEN sattach$(star, p2) = ""
IF p1 = 2 THEN pattach$(star, p2) = ""
GOTO 100

450 REM enter/space/>
IF p1 <> 1 OR p2 <> numstar(star) + 1 GOTO 452
IF star = 1 THEN star = 0
IF star = 2 THEN star = 1
IF star = 0 THEN star = 2
p1 = 1: p2 = numstar(star) + 1
GOTO 100
452 IF p1 = 1 THEN attach$ = sattach$(star, p2)
IF p1 = 2 THEN attach$ = pattach$(star, p2)
IF attach$ = "" GOTO 300
app$ = reader$
IF k1 = 62 THEN app$ = editor$
ext$ = RIGHT$(attach$, 3)
IF ext$ = "txt" THEN
   GOSUB 5500: REM egacolor
   SHELL app$ + " " + locdir$ + attach$
END IF
IF ext$ = "mnu" THEN
   GOSUB 5500: REM egacolor
   SHELL "xtra\eg " + locdir$ + attach$ + " " + app$
END IF
IF ext$ = "hex" THEN
   SHELL "sub\hexworld " + locdir$ + attach$
END IF
GOTO 100

460 REM sysmap help
SCREEN 0
SHELL "xtra\eg help\sysmap\sysmap.mnu " + reader$
GOTO 100

470 REM help/quit hint
x = 590: y = 469: word$ = "H: Help": GOSUB 5100
x = 590: y = 479: word$ = "Q: Quit": GOSUB 5100
RETURN

480 REM edit data file
GOSUB 2050: REM save file
GOSUB 5500: REM egacolor
SHELL editor$ + " " + sysfile$
GOTO 90

490 REM deg
IF p1 = 1 GOTO 300
IF k1 = 49 THEN pdeg(star, p2) = pdeg(star, p2) - 5
IF k1 = 50 THEN pdeg(star, p2) = pdeg(star, p2) + 5
IF pdeg(star, p2) < 0 THEN pdeg(star, p2) = pdeg(star, p2) + 360
IF pdeg(star, p2) > 359 THEN pdeg(star, p2) = pdeg(star, p2) - 360
GOTO 100

500 REM generate star system
IF k1 = 60 THEN hubbreak = 1
IF k1 <> 60 THEN hubbreak = 0
REM query to make sure
GOSUB 1100: REM ready input
PRINT "You want to overwrite the current star system?"
GOSUB 9000: REM get yn$
IF yn$ = "n" GOTO 100
IF hubbreak = 1 THEN GOSUB 5560: REM hub-breaker
502 REM single or double system
prob(1) = syst(1)
prob(2) = syst(1) + syst(2)
numsys = FNout(2)
IF stcsn > 0 THEN numsys = stcsn: REM command line override
stcsn = numsys: REM hub-holder
starcnt = 0
FOR a = 1 TO numsys
   REM number of stars
   prob(1) = syst(3)
   prob(2) = syst(3) + syst(4)
   prob(3) = syst(3) + syst(4) + syst(5)
   numstar(a) = FNout(3)
   IF stcn(a) > 0 THEN numstar(a) = stcn(a): REM cmdline override
   stcn(a) = numstar(a): REM hub-holder
   REM construct stars probability chart
   sum = 0: bigweigh = 0: bigstar = 0
   FOR b = 1 TO nstars
      sum = sum + starshar(b)
      prob(b) = sum
   NEXT b
   gen1 = 0: REM assuming not 1st generation stars
   REM select stars and determine weights
   REM and screen out 1st/2nd generation mixes
   FOR b = 1 TO numstar(a)
      DO
         ok = 1
         weight(b, 1) = FNout(nstars)
         t$ = LEFT$(stardes$(weight(b, 1)), 2)
         IF b = 1 AND INSTR("F6G6K6M6", t$) > 0 THEN gen1 = 1
         IF b > 1 AND gen1 = 0 AND INSTR("F6G6K6M6", t$) > 0 THEN ok = 0
      LOOP WHILE ok = 0
      weight(b, 2) = starmass(weight(b, 1))
      IF weight(b, 2) > bigweigh THEN
          bigstar = b
          bigweigh = weight(b, 2)
      END IF
   NEXT b
   REM if first generation, kill all the other stars
   IF gen1 = 1 THEN
      numstar(a) = 1
      bigstar = 1
   END IF
   REM sort stars based on mass
   IF bigstar > 1 THEN
      SWAP weight(1, 1), weight(bigstar, 1)
      SWAP weight(1, 2), weight(bigstar, 2)
   END IF
   IF numstar(a) = 3 AND weight(3, 2) > weight(2, 2) THEN
      SWAP weight(2, 1), weight(3, 1)
      SWAP weight(2, 2), weight(3, 2)
   END IF
   REM assign star values
   FOR b = 1 TO numstar(a)
      c = weight(b, 1)
      IF stc(a, b) > 0 THEN c = stc(a, b): REM cmdline override
      stc(a, b) = c: REM hub-holder
      starcnt = starcnt + 1
      sname$(a, b) = sysname2$ + " " + CHR$(64 + starcnt)
      scomment$(a, b) = stardes$(c)
      sattach$(a, b) = ""
      ssiz(a, b) = starsiz(c)
      scol(a, b) = starcol(c)
   NEXT b
   REM are any of the stars white/black dwarfs?
   dwarf = 0
   FOR b = 1 TO numstar(a)
      IF LEFT$(scomment$(a, b), 3) = "DW:" THEN dwarf = 1
      IF LEFT$(scomment$(a, b), 3) = "DB:" THEN dwarf = 1
   NEXT b
   REM find number of possible planets / 1st orbit / biozone
   c = weight(1, 1)
   numpp = FNroll(starpl$(c))
   orbitone = star1st(c)
   IF dwarf = 1 AND orbitone < 4 THEN orbitone = 4
   biozone = starbio(c)
   REM generate planets
   plcnt = 0: plcnt2 = 0
   FOR b = 1 TO numpp
      IF b >= orbitone THEN
         REM planetary probability chart
         sum = 0
         FOR d = 1 TO nplanets
            IF b < biozone THEN sum = sum + plsin(d)
            IF b = biozone THEN sum = sum + plsbio(d)
            IF b > biozone THEN sum = sum + plsout(d)
            prob(d) = sum
         NEXT d
         REM roll planet type
         e = FNout(nplanets)
         REM white/black dwarf atmosphere stripping
         IF dwarf = 1 THEN
            IF b < 10 AND (e = 2 OR e = 3) THEN e = 21: REM gas core
            IF b < 9 AND (e = 5 OR (e >= 9 AND e <= 20)) THEN e = 8
         END IF
         REM determine planetary stats
         IF plcode$(e) <> "0" AND (gen1 = 0 OR e = 2 OR e = 3) THEN
            plcnt = plcnt + 1
            porbit(a, plcnt) = b
            psiz(a, plcnt) = plsize(e)
            pcol(a, plcnt) = plcolor(e)
            IF RND < .1 AND plcode$(e) <> "F" THEN
               pex(a, plcnt) = (INT(RND * 11) - 5) * 5
               pey(a, plcnt) = (INT(RND * 11) / 10) + .5
            ELSE
               pex(a, plcnt) = 0
               pey(a, plcnt) = 1
            END IF
            pdeg(a, plcnt) = INT(RND * 360)
            pmoons(a, plcnt) = FNroll(plmoon$(e))
            pcomment$(a, plcnt) = pldes$(e)
            REM planet naming
            IF a = 1 THEN bb$ = " "
            IF a = 2 THEN bb$ = " B"
            IF plcode$(e) <> "A" AND plcode$(e) <> "F" THEN
               plcnt2 = plcnt2 + 1
               pname$(a, plcnt) = sysname2$ + bb$ + LTRIM$(STR$(plcnt2))
            END IF
            IF plcode$(e) = "A" THEN
               starcnt = starcnt + 1
               pname$(a, plcnt) = sysname2$ + " " + CHR$(64 + starcnt)
               newweigh = 1000000
               DO UNTIL newweigh <= bigweigh
                  REM construct stars probability chart
                  sum = 0
                  FOR b2 = 1 TO nstars
                     sum = sum + starshar(b2)
                     prob(b2) = sum
                  NEXT b2
                  REM determine star type
                  e2 = FNout(nstars)
                  REM assign stats
                  pcomment$(a, plcnt) = stardes$(e2)
                  psiz(a, plcnt) = starsiz(e2)
                  pcol(a, plcnt) = starcol(e2)
                  newweigh = starmass(e2)
                  t$ = LEFT$(stardes$(e2), 2)
                  IF gen1 = 0 AND INSTR("F6G6K6M6", t$) > 0 THEN
                     pex(a, plcnt) = (INT(RND * 11) - 5) * 5
                     pey(a, plcnt) = (INT(RND * 11) / 10) + .5
                  END IF
               LOOP
            END IF
            IF plcode$(e) = "F" THEN
               plcnt3 = plcnt - plcnt2
               pname$(a, plcnt) = "Belt" + bb$ + LTRIM$(STR$(plcnt3))
            END IF
            pattach$(a, plcnt) = ""
            porbcol(a, plcnt) = FNorbcol(a, plcnt)
         END IF
      END IF
   NEXT b
   numpl(a) = plcnt
NEXT a
p1 = 2: p2 = 1
GOTO 100

600 REM change object color
IF p1 = 1 AND p2 = numstar(star) + 1 GOTO 300
IF p1 = 1 AND k1 = 79 GOTO 300
IF k1 = 67 THEN k3 = 1: REM modifying planet color
IF k1 = 79 THEN k3 = 2: REM modifying orbit color
REM menu head
SCREEN 0: CLS : COLOR 14
PRINT "Choose Color for ";
IF k3 = 1 THEN
   IF p1 = 1 THEN tmp$ = sname$(star, p2)
   IF p1 = 2 THEN tmp$ = pname$(star, p2)
ELSE
   tmp$ = "Orbit" + STR$(porbit(star, p2))
END IF
PRINT tmp$
PRINT "-----------------";
PRINT STRING$(LEN(tmp$), "-")
PRINT
REM find current color (store as tmp2)
IF k3 = 1 THEN
   IF p1 = 1 THEN
      tmp2 = scol(star, p2)
   ELSE
      tmp2 = pcol(star, p2)
   END IF
ELSE
   tmp2 = porbcol(star, p2)
END IF
REM 1st menu item
IF tmp2 = 0 THEN
   COLOR 24
ELSE
   COLOR 8
END IF
PRINT "(A) Black"
REM rest of menu
FOR a = 1 TO 15
   IF tmp2 = a THEN
      COLOR a + 16
   ELSE
      COLOR a
   END IF
   PRINT "("; CHR$(a + 65); ") "; colors$(a)
NEXT a
IF k3 = 2 THEN
   COLOR 11
   PRINT : PRINT "Warning: Orbit colors get recalculated often."
   PRINT "         Make this change at the very end."
END IF
610 REM get new color
GOSUB 1000
IF k2 = 1 GOTO 610
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 27 OR k1 = 81 GOTO 100: REM esc/q
IF k1 >= 65 AND k1 <= 80 GOTO 620
GOTO 610
620 REM adjust color
IF k3 = 1 THEN
   IF p1 = 1 THEN scol(star, p2) = k1 - 65
   IF p1 = 2 THEN pcol(star, p2) = k1 - 65
ELSE
   porbcol(star, p2) = k1 - 65
END IF
GOTO 100

640 REM name/description
IF p1 = 1 AND p2 = numstar(star) + 1 GOTO 300
GOSUB 1100: REM ready input line
IF k1 = 78 THEN INPUT "Name (17 chars max): ", tmp$
IF k1 = 68 THEN INPUT "Description (26 chars max): ", tmp$
IF tmp$ = "" GOTO 100
tmp$ = LTRIM$(RTRIM$(tmp$))
IF k1 = 78 AND LEN(tmp$) > 17 THEN tmp$ = LEFT$(tmp$, 17)
IF k1 = 68 AND LEN(tmp$) > 26 THEN tmp$ = LEFT$(tmp$, 26)
IF k1 = 78 AND p1 = 1 THEN sname$(star, p2) = tmp$
IF k1 = 68 AND p1 = 1 THEN scomment$(star, p2) = tmp$
IF k1 = 78 AND p1 = 2 THEN pname$(star, p2) = tmp$
IF k1 = 68 AND p1 = 2 THEN pcomment$(star, p2) = tmp$
GOTO 100

660 REM moons
IF p1 = 1 GOTO 300
GOSUB 1100: REM ready input line
INPUT "# of Moons: ", tmp$
IF tmp$ = "" GOTO 100
tmp2 = VAL(tmp$)
IF tmp2 < 0 OR tmp2 > 35 THEN GOTO 660
pmoons(star, p2) = tmp2
GOTO 100

680 REM change planet
IF p1 = 1 GOTO 300
addpl = 0
GOSUB 690: REM planet menu
682 GOSUB 1000
IF k2 = 1 GOTO 682
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 27 GOTO 100: REM esc
tmp2 = 0
FOR a = 1 TO nplanets
   IF k1 = ASC(plcode$(a)) THEN tmp2 = a
NEXT a
IF tmp2 = 0 GOTO 682
IF k1 = 65 GOTO 685
IF pldes$(tmp2) = "Empty" GOTO 687
pcol(star, p2) = plcolor(tmp2)
psiz(star, p2) = plsize(tmp2)
pcomment$(star, p2) = pldes$(tmp2)
porbcol(star, p2) = FNorbcol(star, p2)
GOTO 100
685 REM solar companion
SCREEN 12
desnow$ = pcomment$(star, p2)
GOSUB 710: REM star menu
GOSUB 720: REM get input
IF tmp$ = "" GOTO 100
pcol(star, p2) = starcol(tmp2)
psiz(star, p2) = starsiz(tmp2)
pcomment$(star, p2) = stardes$(tmp2)
porbcol(star, p2) = FNorbcol(star, p2)
GOTO 100
687 REM empty
bye = p2
GOSUB 850: REM remove world
IF p2 >= numpl(star) THEN p2 = p2 - 1
IF p2 = 0 THEN
   p1 = 1
   p2 = 1
END IF
GOTO 100

690 REM planet menu
SCREEN 0: CLS : COLOR 14
PRINT "Choose Planet Type"
PRINT "------------------"
half = INT(nplanets / 2)
IF half <> nplanets / 2 THEN half = half + 1
FOR a = 1 TO nplanets
IF a <= half THEN
   LOCATE a + 3, 1
ELSE
   LOCATE a - half + 3, 41
END IF
IF pcomment$(star, p2) = pldes$(a) AND addpl = 0 THEN
   COLOR 10
ELSE
   COLOR 11
END IF
IF a = 1 AND MID$(pcomment$(star, p2), 3, 1) = ":" THEN COLOR 10
PRINT "(" + plcode$(a) + ") " + pldes$(a)
NEXT a
RETURN

700 REM change star
IF p1 = 2 AND MID$(pcomment$(star, p2), 3, 1) = ":" GOTO 685
IF p1 = 2 GOTO 300
IF p1 = 1 AND p2 = numstar(star) + 1 GOTO 300
desnow$ = scomment$(star, p2)
addpl = 0
GOSUB 710: REM star menu
GOSUB 720: REM get input
IF tmp$ = "" GOTO 100
scol(star, p2) = starcol(tmp2)
ssiz(star, p2) = starsiz(tmp2)
scomment$(star, p2) = stardes$(tmp2)
FOR a = 1 TO numpl(star)
   porbcol(star, a) = FNorbcol(star, a)
NEXT a
GOTO 100

710 REM star menu
CLS : COLOR 14
PRINT "Choose Star Type"
PRINT "----------------"
half = INT(nstars / 2)
IF half <> nstars / 2 THEN half = half + 1
FOR a = 1 TO nstars
IF a <= half THEN
   LOCATE a + 3, 1
ELSE
   LOCATE a - half + 3, 41
END IF
IF desnow$ = stardes$(a) AND addpl = 0 THEN
   COLOR 10
ELSE
   COLOR 11
END IF
PRINT stardes$(a)
NEXT a
RETURN

720 REM get input
LOCATE 28, 1: COLOR 10
PRINT SPACE$(79); : LOCATE 28, 1
INPUT "Enter star code: ", tmp$
tmp$ = RTRIM$(LTRIM$(UCASE$(tmp$)))
tmp2 = 0
FOR a = 1 TO nstars
   IF tmp$ = LEFT$(stardes$(a), 2) THEN tmp2 = a
NEXT a
IF tmp2 = 0 AND tmp$ <> "" GOTO 720
RETURN

730 REM add planet
GOSUB 1100: REM get orbit number
INPUT "Orbit #: ", tmp$
IF tmp$ = "" GOTO 100
tmp1 = VAL(tmp$)
IF tmp1 < 1 OR tmp1 > 21 GOTO 730
REM find place in world list
tmp3 = 0: ok = 1
FOR a = 1 TO numpl(star)
   IF porbit(star, a) = tmp1 THEN ok = 0
   IF porbit(star, a) < tmp1 THEN tmp3 = tmp3 + 1
NEXT a
tmp3 = tmp3 + 1
IF ok = 0 GOTO 730
REM get planet type
addpl = 1
GOSUB 690: REM planet menu
735 GOSUB 1000
IF k2 = 1 GOTO 735
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 27 GOTO 100: REM esc
tmp4 = 0
FOR a = 1 TO nplanets
   IF k1 = ASC(plcode$(a)) THEN tmp4 = a
NEXT a
IF tmp4 = 0 GOTO 735
IF tmp4 = 1 GOTO 740
IF pldes$(tmp4) = "Empty" GOTO 100
tmp5 = 2
GOTO 750
740 REM solar companion
SCREEN 12
desnow$ = pcomment$(star, p2)
GOSUB 710: REM star menu
GOSUB 720: REM get input
IF tmp$ = "" GOTO 100
tmp5 = 1
750 hi = tmp3: GOSUB 860: REM make room
REM assign new planet's stats
porbit(star, tmp3) = tmp1
IF tmp5 = 1 THEN
   pcol(star, tmp3) = starcol(tmp2)
   psiz(star, tmp3) = starsiz(tmp2)
   pcomment$(star, tmp3) = stardes$(tmp2)
END IF
IF tmp5 = 2 THEN
   pcol(star, tmp3) = plcolor(tmp4)
   psiz(star, tmp3) = plsize(tmp4)
   pcomment$(star, tmp3) = pldes$(tmp4)
END IF
IF RND < .1 AND plcode$(tmp4) <> "F" THEN
   pex(star, tmp3) = (INT(RND * 11) - 5) * 5
   pey(star, tmp3) = (INT(RND * 11) / 10) + .5
ELSE
   pex(star, tmp3) = 0
   pey(star, tmp3) = 1
END IF
porbcol(star, tmp3) = FNorbcol(star, tmp3)
pdeg(star, tmp3) = INT(RND * 360)
pmoons(star, tmp3) = FNroll(plmoon$(tmp4))
pname$(star, tmp3) = ""
pattach$(star, tmp3) = ""
p1 = 2: p2 = tmp3
GOTO 100

800 REM change orbit number (move planet)
IF p1 = 1 GOTO 300
GOSUB 1100: REM ready input
INPUT "New Orbit #: ", tmp$
IF tmp$ = "" GOTO 100
tmp1 = VAL(tmp$)
IF tmp1 < 1 OR tmp1 > 21 GOTO 800
ok = 1: tmp3 = 0
FOR a = 1 TO numpl(star)
   IF porbit(star, a) = tmp1 THEN ok = 0
   IF porbit(star, a) < tmp1 THEN tmp3 = tmp3 + 1
NEXT a
tmp3 = tmp3 + 1
IF ok = 0 GOTO 800
hi = tmp3: GOSUB 860: REM make room
IF p2 >= hi THEN p2 = p2 + 1
REM transfer
porbit(star, tmp3) = tmp1
psiz(star, tmp3) = psiz(star, p2)
pcol(star, tmp3) = pcol(star, p2)
pex(star, tmp3) = pex(star, p2)
pey(star, tmp3) = pey(star, p2)
porbcol(star, tmp3) = FNorbcol(star, tmp3)
pdeg(star, tmp3) = pdeg(star, p2)
pmoons(star, tmp3) = pmoons(star, p2)
pname$(star, tmp3) = pname$(star, p2)
pcomment$(star, tmp3) = pcomment$(star, p2)
pattach$(star, tmp3) = pattach$(star, p2)
bye = p2: GOSUB 850: REM remove old one
p2 = tmp3
IF p2 >= bye THEN p2 = p2 - 1
IF p2 = 0 THEN p2 = 1
GOTO 100

850 REM remove world #bye
IF bye < numpl(star) THEN
   FOR a = bye TO numpl(star) - 1
      porbit(star, a) = porbit(star, a + 1)
      porbcol(star, a) = porbcol(star, a + 1)
      psiz(star, a) = psiz(star, a + 1)
      pcol(star, a) = pcol(star, a + 1)
      pex(star, a) = pex(star, a + 1)
      pey(star, a) = pey(star, a + 1)
      pdeg(star, a) = pdeg(star, a + 1)
      pmoons(star, a) = pmoons(star, a + 1)
      pname$(star, a) = pname$(star, a + 1)
      pcomment$(star, a) = pcomment$(star, a + 1)
      pattach$(star, a) = pattach$(star, a + 1)
   NEXT a
END IF
numpl(star) = numpl(star) - 1
RETURN

860 REM make room
IF hi <= numpl(star) THEN
   FOR a = numpl(star) TO hi STEP -1
      porbit(star, a + 1) = porbit(star, a)
      porbcol(star, a + 1) = porbcol(star, a)
      psiz(star, a + 1) = psiz(star, a)
      pcol(star, a + 1) = pcol(star, a)
      pex(star, a + 1) = pex(star, a)
      pey(star, a + 1) = pey(star, a)
      pdeg(star, a + 1) = pdeg(star, a)
      pmoons(star, a + 1) = pmoons(star, a)
      pname$(star, a + 1) = pname$(star, a)
      pcomment$(star, a + 1) = pcomment$(star, a)
      pattach$(star, a + 1) = pattach$(star, a)
   NEXT a
END IF
numpl(star) = numpl(star) + 1
RETURN

900 REM change eccentricity
tmp1 = (pex(star, p2) / 5) + 50
tmp2 = pey(star, p2) * 10
IF k1 = 51 THEN tmp1 = tmp1 - 1
IF k1 = 52 THEN tmp1 = tmp1 + 1
IF k1 = 53 THEN tmp2 = tmp2 - 1
IF k1 = 54 THEN tmp2 = tmp2 + 1
IF tmp1 = 0 THEN tmp1 = 99
IF tmp1 = 100 THEN tmp1 = 1
IF tmp2 = 0 THEN tmp2 = 99
IF tmp2 = 100 THEN tmp2 = 1
pex(star, p2) = (tmp1 - 50) * 5
pey(star, p2) = tmp2 / 10
porbcol(star, p2) = FNorbcol(star, p2)
GOTO 100

1000 REM get character from keyboard
k1 = 0: k2 = 0
1010 k$ = INKEY$
IF k$ = "" THEN GOTO 1010
k1 = ASC(k$)
IF k1 <> 0 THEN RETURN
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
RETURN

1100 REM erase status line
FOR sltmp = 26 TO 30
   LOCATE sltmp, 1: COLOR 10
   IF sltmp MOD 2 = 1 THEN
      PRINT STRING$(79, 196);
   ELSE
      PRINT SPACE$(79);
   END IF
NEXT sltmp
LOCATE 28, 1: COLOR 11
RETURN

2000 REM load star system
OPEN "r", 1, sysfile$
t = LOF(1)
CLOSE #1
IF t = 0 THEN SHELL "erase " + sysfile$
IF t = 0 GOTO 502
OPEN "i", 1, sysfile$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   t$ = RTRIM$(t$)
   IF t$ = "" GOTO 2010
   IF LEFT$(t$, 1) = "#" GOTO 2010
   IF LEFT$(t$, 12) = "System Name:" THEN
      IF LEN(t$) > 13 THEN
         sysname$ = RIGHT$(t$, LEN(t$) - 13)
      ELSE
         sysname$ = ""
      END IF
   END IF
   IF t$ = "Primary:" THEN
      numsys = 1: stcsn = 1
      numstar(1) = 0: stcn(1) = 0
      numpl(1) = 0
   END IF
   IF t$ = "Far Companion:" THEN
      numsys = 2: stcsn = 2
      numstar(2) = 0: stcn(2) = 0
      numpl(2) = 0
   END IF
   IF LEFT$(t$, 1) = "0" THEN
      numstar(numsys) = numstar(numsys) + 1
      stcn(numsys) = stcn(numsys) + 1
      ssiz(numsys, numstar(numsys)) = FNnumber(MID$(t$, 4, 1))
      scol(numsys, numstar(numsys)) = ASC(MID$(t$, 5, 1)) - 65
      sname$(numsys, numstar(numsys)) = RTRIM$(MID$(t$, 18, 17))
      scomment$(numsys, numstar(numsys)) = RTRIM$(MID$(t$, 35, 25))
      stc(numsys, numstar(numsys)) = FNstn(MID$(t$, 35, 2))
      IF LEN(t$) > 60 THEN
         sattach$(numsys, numstar(numsys)) = RTRIM$(RIGHT$(t$, LEN(t$) - 60))
      ELSE
         sattach$(numsys, numstar(numsys)) = ""
      END IF
   END IF
   IF MID$(t$, 15, 1) = "-" THEN
      numpl(numsys) = numpl(numsys) + 1
      porbit(numsys, numpl(numsys)) = FNnumber(LEFT$(t$, 1))
      porbcol(numsys, numpl(numsys)) = ASC(MID$(t$, 3, 1)) - 65
      psiz(numsys, numpl(numsys)) = FNnumber(MID$(t$, 4, 1))
      pcol(numsys, numpl(numsys)) = ASC(MID$(t$, 5, 1)) - 65
      pex(numsys, numpl(numsys)) = (VAL(MID$(t$, 7, 2)) - 50) * 5
      pey(numsys, numpl(numsys)) = VAL(MID$(t$, 9, 2)) / 10
      pdeg(numsys, numpl(numsys)) = VAL(MID$(t$, 12, 3))
      pmoons(numsys, numpl(numsys)) = FNnumber(MID$(t$, 16, 1))
      pname$(numsys, numpl(numsys)) = RTRIM$(MID$(t$, 18, 17))
      pcomment$(numsys, numpl(numsys)) = RTRIM$(MID$(t$, 35, 26))
      IF LEN(t$) > 60 THEN
         pattach$(numsys, numpl(numsys)) = RTRIM$(RIGHT$(t$, LEN(t$) - 60))
      ELSE
         pattach$(numsys, numpl(numsys)) = ""
      END IF
   END IF
2010 LOOP
CLOSE 1
RETURN

2050 REM save star system
OPEN "o", 1, sysfile$
OPEN "i", 2, "data\sysmap\header.dat"
DO UNTIL EOF(2)
   LINE INPUT #2, t$
   PRINT #1, t$
LOOP
CLOSE 2
PRINT #1, "System Name: "; sysname$
FOR a = 1 TO numsys
   IF a = 1 THEN PRINT #1, "Primary:"
   IF a = 2 THEN PRINT #1, "Far Companion:"
   FOR b = 1 TO numstar(a)
      t$ = "0--"
      t$ = t$ + FNletter$(ssiz(a, b))
      t$ = t$ + CHR$(scol(a, b) + 65) + SPACE$(12)
      t$ = t$ + sname$(a, b) + SPACE$(17 - LEN(sname$(a, b)))
      t$ = t$ + scomment$(a, b) + SPACE$(26 - LEN(scomment$(a, b)))
      t$ = t$ + sattach$(a, b)
      t$ = RTRIM$(t$)
      PRINT #1, t$
   NEXT b
   FOR b = 1 TO numpl(a)
      t$ = FNletter$(porbit(a, b)) + "-"
      t$ = t$ + CHR$(porbcol(a, b) + 65)
      t$ = t$ + FNletter$(psiz(a, b))
      t$ = t$ + CHR$(pcol(a, b) + 65) + "-"
      t1$ = LTRIM$(STR$((pex(a, b) / 5) + 50))
      IF LEN(t1$) < 2 THEN t1$ = "0" + t1$
      t2$ = LTRIM$(STR$(pey(a, b) * 10))
      IF LEN(t2$) < 2 THEN t2$ = "0" + t2$
      t3$ = LTRIM$(STR$(pdeg(a, b)))
      IF LEN(t3$) < 3 THEN t3$ = "0" + t3$
      IF LEN(t3$) < 3 THEN t3$ = "0" + t3$
      t$ = t$ + t1$ + t2$ + "-" + t3$ + "-"
      t$ = t$ + FNletter$(pmoons(a, b)) + " "
      t$ = t$ + pname$(a, b) + SPACE$(17 - LEN(pname$(a, b)))
      t$ = t$ + pcomment$(a, b) + SPACE$(26 - LEN(pcomment$(a, b)))
      t$ = t$ + pattach$(a, b)
      t$ = RTRIM$(t$)
      PRINT #1, t$
   NEXT b
NEXT a
CLOSE 1
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
COLOR 11: GOSUB 5005
GET (1, 1)-(l, 5), letimage(1, z)
COLOR 0: GOSUB 5005
NEXT z
CLOSE
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

5020 REM read stars.dat
OPEN "i", 1, "data\sysmap\stars.dat"
nstars = 0
DO UNTIL EOF(1)
INPUT #1, t$
t$ = RTRIM$(t$)
IF t$ = "" GOTO 5025
IF LEFT$(t$, 1) = "#" GOTO 5025
nstars = nstars + 1
stardes$(nstars) = RTRIM$(LEFT$(t$, 25))
starshar(nstars) = VAL(MID$(t$, 30, 6))
starmass(nstars) = VAL(MID$(t$, 39, 4))
starpl$(nstars) = RTRIM$(LTRIM$(MID$(t$, 45, 7)))
star1st(nstars) = VAL(MID$(t$, 53, 3))
starbio(nstars) = VAL(MID$(t$, 57, 3))
starcol(nstars) = ASC(MID$(t$, 61, 1)) - 65
starsiz(nstars) = FNnumber(MID$(t$, 62, 1))
5025 LOOP
CLOSE 1
RETURN

5030 REM read planets.dat
OPEN "i", 1, "data\sysmap\planets.dat"
nplanets = 0
DO UNTIL EOF(1)
INPUT #1, t$
t$ = RTRIM$(t$)
IF t$ = "" GOTO 5035
IF LEFT$(t$, 1) = "#" GOTO 5035
nplanets = nplanets + 1
plcode$(nplanets) = LEFT$(t$, 1)
plsize(nplanets) = VAL(MID$(t$, 3, 1))
plcolor(nplanets) = ASC(MID$(t$, 5, 1)) - 65
pldes$(nplanets) = RTRIM$(MID$(t$, 7, 21))
plsin(nplanets) = VAL(MID$(t$, 28, 3))
plsbio(nplanets) = VAL(MID$(t$, 36, 3))
plsout(nplanets) = VAL(MID$(t$, 44, 3))
plmoon$(nplanets) = LTRIM$(RTRIM$(MID$(t$, 50, 5)))
5035 LOOP
CLOSE 1
RETURN

5040 REM read system.dat
OPEN "i", 1, "data\sysmap\system.dat"
count = 0
DO UNTIL EOF(1)
INPUT #1, t$
t$ = RTRIM$(t$)
IF t$ = "" GOTO 5045
IF LEFT$(t$, 1) = "#" GOTO 5045
IF RIGHT$(t$, 1) = "%" THEN t$ = LEFT$(t$, LEN(t$) - 1)
tmp = INSTR(t$, ":")
IF tmp > 0 THEN t$ = RIGHT$(t$, LEN(t$) - tmp)
count = count + 1
syst(count) = VAL(t$)
5045 LOOP
CLOSE 1
RETURN

5090 REM read 15 colors
OPEN "i", 1, "xtra\colors.dat"
LINE INPUT #1, tmp$
FOR a = 1 TO 15
   LINE INPUT #1, tmp$
   colors$(a) = RIGHT$(tmp$, LEN(tmp$) - 4)
NEXT a
CLOSE 1
RETURN

5100 REM subroutine: print word
y = y - 4
l = LEN(word$)
IF l = 0 THEN RETURN
FOR aw = -1 TO 5
   LINE (x - 1, y + aw)-(x + l * 6 - 1, y + aw), 0
NEXT aw
word$ = UCASE$(word$)
FOR aw = 1 TO l
let$ = MID$(word$, aw, 1)
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
NEXT aw
RETURN

5500 REM egacolor gold on blue
SCREEN 0
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
RETURN

5550 REM stars on command line?
GOSUB 5560: REM clear stc
IF starc$ = "" THEN RETURN
REM remove spaces and parentheses from starc$
a = 1
DO WHILE a <= LEN(starc$)
 b$ = MID$(starc$, a, 1)
 IF b$ = " " OR b$ = "(" OR b$ = ")" THEN
  starc$ = FNrmchar$(starc$, a)
 ELSE
  a = a + 1
 END IF
LOOP
REM allocate stars into stc$
a = INSTR(starc$, "/")
IF a > 0 THEN
   b1 = (a - 1) / 2
   b2 = (LEN(starc$) - a) / 2
   stcsn = 2
ELSE
   b1 = LEN(starc$) / 2
   b2 = 0
   stcsn = 1
END IF
FOR c = 1 TO b1
 stc(1, c) = FNstn(UCASE$(MID$(starc$, c * 2 - 1, 2)))
NEXT c
IF b2 > 0 THEN
 FOR c = 1 TO b2
  stc(2, c) = FNstn(UCASE$(MID$(starc$, c * 2 - 1 + a, 2)))
 NEXT c
END IF
stcn(1) = b1
stcn(2) = b2
RETURN

5560 REM clear stc
FOR a = 1 TO 2
 stcn(a) = 0
 FOR b = 1 TO 5
  stc(a, b) = 0
 NEXT b
NEXT a
stcsn = 0
RETURN

5600 REM initial variable settings
pi# = 3.1415926#
push = 6: REM distance of the 1st orbit
basea = 320: REM x-coord of the hub
star = 1: REM initial system of focus
starpos$(1) = "Primary"
starpos$(2) = "Secondary"
starpos$(3) = "Tertiary"
p1 = 2: REM arrow initially on lower (planet) menu
p2 = 1: REM arrow initially on 1st item (planet) of lower menu
RETURN

5700 REM gal.cfg
OPEN "i", 1, "gal.cfg"
INPUT #1, t$: l = LEN(t$)
editor$ = RIGHT$(t$, l - 7)
INPUT #1, t$: l = LEN(t$)
reader$ = RIGHT$(t$, l - 7)
INPUT #1, t$: clrmode = VAL(RIGHT$(t$, 1))
CLOSE 1
RETURN

5800 REM error trapping
IF ERR = 5 THEN RESUME NEXT
SCREEN 0: CLS
PRINT "Warning: Error #"; ERR; "at"; ERL; "detected"
PRINT "Quiting..."
END

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

9000 REM y/n
yn$ = ""
GOSUB 1000
IF k2 = 1 GOTO 9000
IF k1 >= 97 AND k1 <= 122 THEN k1 = k1 - 32
IF k1 = 27 OR k1 = 81 THEN yn$ = "n": REM esc/q
IF k1 = 78 THEN yn$ = "n": REM N
IF k1 = 89 THEN yn$ = "y": REM Y
IF yn$ = "" GOTO 9000
RETURN

10000 REM end
GOSUB 2050: REM save star system map
10005 SCREEN 0: COLOR 7: CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "    Email:  jimv@empirenet.com"
PRINT "            JimVassila@aol.com"
PRINT
PRINT " Homepage:  http://members.aol.com/jimvassila"
PRINT
END

SUB savescr (filename$, sx, sy, ex, ey, nbits, imgnum)
'SAVESCR V0.6 - Screen Capture Function for Qbasic.
'By: Aaron Zabudsky <zabudsk@ecf.utoronto.ca>
'Date: July 17, 1997
'Free - Comments welcome.
'
'Usage: filename$ - Name of the file you want to capture to. Overwrites any
'                   old image that may be under that name.
'       sx        - Starting X coordinate
'       sy        - Starting Y coordinate
'       ex        - Ending X coordinate
'       ey        - Ending Y coordinate
'       nbits     - Number of bits you want in your bitmap. Use 1, 4 or 8.
'                   Use nbits=1 for SCREEN 11
'                   Use nbits=4 for SCREEN 12
'                   Use nbits=8 for SCREEN 13
'       imgnum    - The current number of the image you are saving to.
'                   This can be anything if you have specified a filename
'                   If you have specified a blank filename (""), Autonumbering
'                   is enabled and if you specify a number here, it will save
'                   the image as CAP0.BMP, CAP1.BMP,...,CAP1000.BMP,etc.
'                   If you leave a variable in this spot when you call the
'                   capture function, the function will automatically increment
'                   the variable, so you can "auto-capture" a series of
'                   pictures without worrying about numbers.
'
' e.g. savescr "test.bmp",0,0,639,479,4,0
'      will capture the entire SCREEN 12 screen with 16 colours and save it
'      to test.bmp.
'      savescr "",0,0,319,199,8,t
'      will capture the entire SCREEN 13 screen with 256 colours and save it
'      as CAP#.BMP, where # is the current value of t, it will then increment
'      t.
'      savescr "",0,0,639,479,1,(t)
'      will capture the entire SCREEN 11 screen with 2 colours and save it
'      as CAP#.BMP as in the previous example, but this time t will not be
'      incremented.


IF filename$ = "" THEN
   filename$ = "CAP" + LTRIM$(RTRIM$(STR$(imgnum))) + ".BMP"
   imgnum = imgnum + 1
END IF
OPEN filename$ FOR BINARY AS #1
IF LOF(1) <> 0 THEN
   'Alter this code here if you don't want it to overwrite existing files.
   CLOSE 1
   KILL filename$
   OPEN filename$ FOR BINARY AS #1
END IF

va = &H3C7 'VGA Palette Read Address Register
vd = &H3C9 'VGA Palette Data Register

zero$ = CHR$(0) + CHR$(0) + CHR$(0) + CHR$(0)

'Check extents to order points.
IF sx > ex THEN SWAP sx, ex
IF sy > ey THEN SWAP sy, ey

'Use Windows BMP Header. Size=40
headersize = 40

'Calculate Picture width,height
picwidth = ex - sx + 1
picheight = ey - sy + 1

'Set Colour Information
'Planes [W] - Must be 1
nplanes = 1

'Calculate offset [LW] to start of data
IF nbits = 1 OR nbits = 4 OR nbits = 8 THEN
   offset = 14 + headersize + 4 * (2 ^ nbits)
ELSE
   offset = 14 + headersize
END IF

'Type of file [W] (Should be BM)
ft$ = "BM"

'File Size [LW] (excluding header)
IF nbits = 1 THEN
   IF (picwidth MOD 32) <> 0 THEN
      filesize = 4 * (INT(picwidth / 32) + 1) * picheight
   ELSE
      filesize = (picwidth / 8) * picheight
   END IF
ELSEIF nbits = 4 THEN
   IF (picwidth MOD 8) <> 0 THEN
      filesize = 4 * (INT(picwidth / 8) + 1) * picheight
   ELSE
      filesize = (picwidth / 2) * picheight
   END IF
ELSEIF nbits = 8 THEN
   IF (picwidth MOD 4) <> 0 THEN
      filesize = 4 * (INT(picwidth / 4) + 1) * picheight
   ELSE
      filesize = picwidth * picheight
   END IF
ELSEIF nbits = 24 THEN
   IF (3 * picwidth MOD 4) <> 0 THEN
      filesize = 4 * (INT(3 * picwidth / 4) + 1) * picheight
   ELSE
      filesize = 3 * picwidth * picheight
   END IF
END IF

'Set reserved values [W] (both must be zero)
r1 = 0
r2 = 0

'Compression type [LW] - None
comptype = 0

'Image Size [LW]; Scaling Factors xsize, ysize unused.
imagesize = offset + filesize
xsize = 0
ysize = 0

'Assume all colours used [LW] - 0 means all colours.
coloursused = 0
neededcolours = 0

header$ = ft$ + MKL$(filesize) + MKI$(r1) + MKI$(r2) + MKL$(offset)
infoheader$ = MKL$(headersize) + MKL$(picwidth)
infoheader$ = infoheader$ + MKL$(picheight) + MKI$(nplanes)
infoheader$ = infoheader$ + MKI$(nbits) + MKL$(comptype) + MKL$(imagesize)
infoheader$ = infoheader$ + MKL$(xsize) + MKL$(ysize) + MKL$(coloursused)
infoheader$ = infoheader$ + MKL$(neededcolours)

'Write headers to BMP File.
PUT #1, 1, header$
PUT #1, , infoheader$

'Add palette - Get colours (Write as B0G0R0(0),B1G1R1(0),...)
IF nbits = 1 OR nbits = 4 OR nbits = 8 THEN
   palet$ = ""
   OUT va, 0
   FOR count = 1 TO 2 ^ nbits
      zr = INP(vd) * 4
      zg = INP(vd) * 4
      zb = INP(vd) * 4
      palet$ = palet$ + CHR$(zb) + CHR$(zg) + CHR$(zr) + CHR$(0)
   NEXT count
   PUT #1, , palet$
   palet$ = "" 'Save some memory
END IF


stpoint = POINT(sx, ey + 1)

'BMPs are arranged with the top of the image at the bottom of the file.
'Get points off the screen and pack into bytes depending on the number of
'bits used. Deal with unused bits at the end of the line.
'Check for invalid range.
FOR count2 = ey TO sy STEP -1
   lin$ = ""
   IF nbits = 1 THEN
      count1 = sx
      WHILE count1 <= ex
         IF count1 + 7 > ex THEN
            t = 0
            FOR count0 = 0 TO 7
               p = POINT(count1 + count0, count2)
               IF p < 0 THEN p = 0
               t = t + (2 ^ (7 - count0)) * (p MOD 2)
            NEXT count0
            t2 = ex - count1 + 1
            t = t AND ((2 ^ t2) - 1) * (2 ^ (8 - t2))
            lin$ = lin$ + CHR$(t)
         ELSE
            t = 0
            FOR count0 = 0 TO 7
               p = POINT(count1 + count0, count2)
               IF p < 0 THEN p = 0
               t = t + (2 ^ (7 - count0)) * (p MOD 2)
            NEXT count0
            lin$ = lin$ + CHR$(t)
         END IF
         count1 = count1 + 8
      WEND
   ELSEIF nbits = 4 THEN
      count1 = sx
      WHILE count1 <= ex
         IF count1 = ex THEN
            p = POINT(count1, count2)
            IF p < 0 THEN p = 0
            lin$ = lin$ + CHR$((p MOD 16) * 16)
         ELSE
            p = POINT(count1, count2)
            p2 = POINT(count1 + 1, count2)
            IF p < 0 THEN p = 0
            IF p2 < 0 THEN p2 = 0
            lin$ = lin$ + CHR$((p MOD 16) * 16 + p2)
         END IF
         count1 = count1 + 2
      WEND
   ELSEIF nbits = 8 THEN
      FOR count1 = sx TO ex
         p = POINT(count1, count2)
         IF p < 0 THEN p = 0
         lin$ = lin$ + CHR$(p)
      NEXT count1
   ELSEIF nbits = 24 THEN
      'I'm not sure what to put here. QBasic doesn't support truecolour
      'Unused for now.
   END IF

   'Pad line to LongWord boundary
   IF (LEN(lin$) MOD 4) <> 0 THEN
      lin$ = lin$ + MID$(zero$, 1, 4 - (LEN(lin$) MOD 4))
   END IF

   'Indicate our status
   PSET (sx, count2 + 1), stpoint
   stpoint = POINT(sx, count2)
   IF nbits = 8 THEN
      PSET (sx, count2), 255 - stpoint
   ELSEIF nbits = 4 THEN
      PSET (sx, count2), 15 - stpoint
   ELSEIF nbits = 1 THEN
      PSET (sx, count2), 1 - stpoint
   END IF

   'Write the current line to the BMP file
   PUT #1, , lin$

NEXT count2

'Save some memory
lin$ = ""

PSET (sx, count2 + 1), stpoint

'Close the file
CLOSE

END SUB

