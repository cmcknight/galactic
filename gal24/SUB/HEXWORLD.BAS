
REM HexWorld v1.2
REM Freeware 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com
REM Written in Microsoft QuickBasic version 4.5
REM Includes SAVESCR v0.6 by Aaron Zabudsky <zabudsk@ecf.utoronto.ca>
REM
REM Usage = hexworld <filename> [<worldname>]

DECLARE SUB savescr (filename$, sx!, sy!, ex!, ey!, nbits!, imgnum!)

DIM letimage(13, 44) AS INTEGER
DIM length(44)
DIM col%(490)
DIM place%(40)
DIM name$(40, 2)
DIM colsum(16)
DIM colname$(16)

DEF FNhex (ft, fu, fv)
   tmp = (ft - 1) * 98
   tmp = tmp + ((fu - 1) * 14)
   tmp = tmp + fv
   FNhex = tmp
END DEF

REM disect command line
c$ = COMMAND$
10 IF c$ = "" THEN
   CLS : COLOR 11: LOCATE 5
   INPUT "Enter HexWorld Map File: ", c$
END IF
c$ = LCASE$(RTRIM$(LTRIM$(c$)))
IF c$ = "" GOTO 10005
a = INSTR(c$, " ")
IF a <> 0 THEN
   l = LEN(c$)
   world$ = LTRIM$(RIGHT$(c$, l - a))
   c$ = LEFT$(c$, a - 1)
   REM capitalize world$
   l = LEN(world$)
   FOR b = 1 TO l
      m = ASC(MID$(world$, b, 1))
      IF m >= 97 AND m <= 122 THEN m = m - 32
      n = 0
      IF b > 1 THEN
         IF ASC(MID$(world$, b - 1, 1)) = 32 THEN n = 1
      END IF
      IF b = 1 THEN world$ = CHR$(m) + RIGHT$(world$, l - 1)
      IF b > 1 AND n = 1 THEN
         tmp$ = LEFT$(world$, b - 1) + CHR$(m)
         tmp$ = tmp$ + RIGHT$(world$, l - b)
         world$ = tmp$
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
   f$ = f$ + ".hex"
END IF
IF RIGHT$(f$, 4) <> ".hex" THEN c$ = ""
IF c$ = "" GOTO 10
bmpfile$ = LEFT$(f$, LEN(f$) - 4) + ".bmp"
f$ = locdir$ + f$

GOSUB 5600: REM read colors.dat
GOSUB 5700: REM read configuration
GOSUB 5000: REM read letters.dat -> image data
GOSUB 5200: REM calculate video stuff
GOSUB 1000: REM load hexmap

140 REM graphics mode
CLS
SCREEN 12
GOSUB 5800: REM set palette

150 REM draw world's hex grid
CLS
REM draw blue hexs
COLOR 1
FOR hex = 1 TO 490
   GOSUB 500: REM get t/u/v
   GOSUB 550: REM get cent1/cent2
   GOSUB 600: REM draw hex
   pt = t: pu = u: pv = v
   GOSUB 650: REM fill hex
NEXT hex

REM draw places
IF numplace <> 0 THEN
   FOR np = 1 TO numplace
      hex = place%(np)
      GOSUB 1200: REM draw location
   NEXT np
END IF

IF bmp = 0 THEN
   GOSUB 700: REM color menu
   GOSUB 750: REM quit/readme hint
END IF
LOCATE 2, 5: COLOR 11: PRINT world$

REM set starting location for the magenta circle/cursor
hex = starthex
GOSUB 500: REM get t/u/v
pt = t: pu = u: pv = v

160 REM return here

GOSUB 1100: REM erase status line

REM draw places
IF numplace > 0 THEN
   REM hexnow = FNhex(pt, pu, pv)
   FOR np = 1 TO numplace
      hex = place%(np)
      REM IF hex = hexnow THEN GOSUB 1200: REM draw location
      GOSUB 1200: REM draw location
   NEXT np
END IF

IF bmp = 1 GOTO 285

GOSUB 800: REM draw circle/cursor
IF tog1 = 1 THEN GOSUB 805: REM display hex#

200 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 1 AND k1 = 72 GOTO 210: REM up
IF k2 = 1 AND k1 = 80 GOTO 220: REM down
IF k2 = 1 AND k1 = 75 GOTO 230: REM left
IF k2 = 1 AND k1 = 77 GOTO 240: REM right
IF k2 = 0 AND k1 = 13 GOTO 260: REM enter
IF k2 = 0 AND k1 = 32 GOTO 260: REM space
IF k2 = 1 AND k1 = 82 GOTO 300: REM insert
IF k2 = 1 AND k1 = 83 GOTO 350: REM delete
IF k2 = 0 AND k1 = 12 GOTO 205: REM ctrl-l
IF k2 = 0 AND (k1 = 63 OR k1 = 82) GOTO 490: REM ?/R
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND k1 >= 65 AND k1 <= 80 GOTO 250: REM A-P
IF k2 = 0 AND k1 = 81 GOTO 10000: REM Q
IF k2 = 0 AND (k1 = 5 OR k1 = 60) GOTO 495: REM ctrl-e or <
IF k2 = 0 AND k1 = 19 THEN GOSUB 1050: REM ctrl-s
IF k2 = 0 AND k1 = 24 GOTO 10005: REM ctrl-x
IF k2 = 0 AND k1 = 83 GOTO 270: REM S
IF k2 = 1 AND k1 = 59 GOTO 201: REM F1
IF k2 = 0 AND k1 = 6 GOTO 360: REM ctrl-f
IF k2 = 0 AND k1 = 7 GOTO 370: REM ctrl-g
IF k2 = 0 AND k1 = 62 GOTO 260: REM >
IF k2 = 1 AND k1 = 68 GOTO 280: REM F10
GOTO 200

201 REM Hex Toggle
tmp = tog1
IF tmp = 1 THEN tog1 = 0
IF tmp = 0 THEN tog1 = 1
GOTO 160

205 REM redraw
starthex = FNhex(pt, pu, pv)
GOTO 150

210 REM up
GOSUB 850: REM erase circle
pv = pv - 1
IF pv = 0 THEN pv = 1
GOTO 160

220 REM down
GOSUB 850: REM erase circle
pv = pv + 1
IF pv = 15 THEN pv = 14
GOTO 160

230 REM left
GOSUB 850: REM erase circle
pu = pu - 1
pv = pv - 1
IF pu = 0 THEN
   pt = pt - 1
   pu = 7
   pv = pv + 7
   IF pv > 14 THEN
      z = pv - 14
      pu = pu - z
      pv = pv - z
   END IF
END IF
IF pv = 0 THEN
   pt = pt - 1
   pv = 7 - pu
   pu = 7
END IF
IF pt = 0 THEN pt = 5
GOTO 160

240 REM right
GOSUB 850: REM erase circle
pu = pu + 1
pv = pv + 1
IF pu = 8 THEN
   pt = pt + 1
   pu = 1
   pv = pv - 7
   IF pv < 1 THEN
      z = ABS(pv) + 1
      pu = pu + z
      pv = pv + z
   END IF
END IF
IF pv = 15 THEN
   pt = pt + 1
   pv = 16 - pu
   pu = 1
END IF
IF pt = 6 THEN pt = 1
GOTO 160

250 REM A-P
IF col%(FNhex(pt, pu, pv)) = 1 THEN
   GOSUB 675: REM clear the hex
END IF
col%(FNhex(pt, pu, pv)) = k1 - 65
GOSUB 650: REM fill hex
GOTO 160

260 REM enter/space/>
IF numplace = 0 GOTO 160
hexnow = FNhex(pt, pu, pv)
hexfile$ = ""
FOR np = 1 TO numplace
   hex = place%(np)
   IF hex = hexnow THEN
      hexfile$ = name$(np, 2)
   END IF
NEXT np
IF hexfile$ = "" GOTO 160
app$ = reader$
IF k1 = 62 THEN app$ = editor$
ext$ = RIGHT$(hexfile$, 3)
GOSUB 5500: REM egacolor
IF ext$ = "txt" THEN
   SHELL app$ + " " + locdir$ + hexfile$
END IF
IF ext$ = "mnu" THEN
   SHELL "xtra\eg " + locdir$ + hexfile$ + " " + app$
END IF
starthex = FNhex(pt, pu, pv)
GOTO 140

270 REM Summary
FOR a = 1 TO 16
   colsum(a) = 0
NEXT a
FOR a = 1 TO 490
   colsum(col%(a) + 1) = colsum(col%(a) + 1) + 1
NEXT a
SCREEN 0: CLS : COLOR 14
PRINT "Summary Stats"
PRINT "-------------"
PRINT
COLOR 8
PRINT "Black";
LOCATE , 20: PRINT colsum(1); : LOCATE , 30
PRINT STR$(INT(colsum(1) / 490 * 1000) / 10); "%"
FOR a = 1 TO 15
   COLOR a: PRINT colname$(a + 1);
   LOCATE , 20: PRINT colsum(a + 1); : LOCATE , 30
   PRINT STR$(INT(colsum(a + 1) / 490 * 1000) / 10); "%"
NEXT a
PRINT : COLOR 11
PRINT "Hit any key to return to the map"
GOSUB 900
starthex = FNhex(pt, pu, pv)
GOTO 140

280 REM save screen
bmp = 1: holdhex = FNhex(pt, pu, pv): GOTO 150
285 bmp = 0
savescr bmpfile$, 0, 0, 639, 379, 4, 0
SCREEN 0: CLS : LOCATE 5: COLOR 11
PRINT
PRINT "World map saved to "; bmpfile$
PRINT
PRINT "Hit any key to return to the map"
PRINT
GOSUB 900
starthex = holdhex
GOTO 140

300 REM insert
GOSUB 1100: REM erase status line
INPUT "Location Name: ", tmp$
tmp$ = RTRIM$(LTRIM$(tmp$))
IF tmp$ = "" GOTO 160
numplace = numplace + 1
name$(numplace, 1) = tmp$
name$(numplace, 2) = ""
place%(numplace) = FNhex(pt, pu, pv)
305 GOSUB 1100: REM erase status line
PRINT "Do you want to attach a (f)ile, a (m)enu, or (n)othing?"
310 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 70 GOTO 320: REM File
IF k2 = 0 AND k1 = 77 GOTO 330: REM Menu
IF k2 = 0 AND k1 = 78 GOTO 160: REM Nothing
GOTO 310
320 GOSUB 1100: REM erase status line
INPUT "Enter file name (8 chars max, no extension): ", tmp$
tmp$ = RTRIM$(LTRIM$(tmp$))
IF INSTR(tmp$, ".") > 0 GOTO 320
l = LEN(tmp$)
IF l > 8 GOTO 320
IF l = 0 GOTO 305
tmp$ = tmp$ + ".txt"
name$(numplace, 2) = tmp$
OPEN "r", 1, locdir$ + tmp$
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN
   OPEN "o", 1, locdir$ + tmp$
   PRINT #1, name$(numplace, 1)
   PRINT #1, STRING$(LEN(name$(numplace, 1)), "-")
   PRINT #1, ""
   PRINT #1, ""
   CLOSE 1
END IF
GOSUB 5500: REM egacolor
SHELL editor$ + " " + locdir$ + tmp$
starthex = FNhex(pt, pu, pv)
GOTO 140
330 GOSUB 1100: REM erase status line
INPUT "Enter menu name (8 chars max, no extension): ", tmp$
tmp$ = RTRIM$(LTRIM$(tmp$))
IF INSTR(tmp$, ".") > 0 GOTO 330
l = LEN(tmp$)
IF l > 8 GOTO 330
IF l = 0 GOTO 305
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
   PRINT #1, name$(numplace, 1)
   PRINT #1, ""
   PRINT #1, ""
   PRINT #1, "@Light Cyan"
   PRINT #1, "     Topic #1     @topic1.txt"
   PRINT #1, "     Topic #2     @topic2.txt"
   PRINT #1, ""
   CLOSE 1
END IF
GOSUB 5500: REM egacolor
SHELL editor$ + " " + locdir$ + tmp$
starthex = FNhex(pt, pu, pv)
GOTO 140

350 REM delete
b = FNhex(pt, pu, pv)
FOR a = 1 TO numplace
   IF place%(a) = b THEN
      IF a < numplace THEN
         FOR c = a + 1 TO numplace
            place%(c - 1) = place%(c)
            name$(c - 1, 1) = name$(c, 1)
            name$(c - 1, 2) = name$(c, 2)
         NEXT c
      END IF
      numplace = numplace - 1
   END IF
NEXT a
starthex = FNhex(pt, pu, pv)
GOTO 150

360 REM fill section
GOSUB 1100: REM erase status line
PRINT "Fifth-Section Fill / Choose a Color"
362 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 >= 65 AND k1 <= 80 GOTO 364: REM A-P
IF k2 = 0 AND (k1 = 81 OR k1 = 27) GOTO 160: REM Q/Esc
GOTO 362
364 REM
FOR a = 1 TO 7
  FOR b = 1 TO 14
     col%(FNhex(pt, a, b)) = k1 - 65
  NEXT b
NEXT a
GOTO 205

370 REM fill entire map
GOSUB 1100: REM erase status line
PRINT "Global Fill / Choose a Color"
372 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 >= 65 AND k1 <= 80 GOTO 374: REM A-P
IF k2 = 0 AND (k1 = 81 OR k1 = 27) GOTO 160: REM Q/Esc
GOTO 372
374 FOR a = 1 TO 490
   col%(a) = k1 - 65
NEXT a
GOTO 205

490 REM hexworld help
GOSUB 5500: REM egacolor
SHELL reader$ + " help\hexworld.txt"
starthex = FNhex(pt, pu, pv)
GOTO 140

495 REM edit map file directly
GOSUB 1050: REM save map
GOSUB 5500: REM egacolor
SHELL editor$ + " " + f$
tmphex = FNhex(pt, pu, pv)
GOSUB 1000: REM load map
starthex = tmphex
GOTO 140

500 REM get t/u/v coordinates of the hex
b = hex
t = INT((b - .5) / 98) + 1: b = b - ((t - 1) * 98)
u = INT((b - .5) / 14) + 1: b = b - ((u - 1) * 14)
v = b
RETURN

545 t = pt: u = pu: v = pv
550 REM get cent1/cent2 (center of the hex)
REM accounting for t-coordinate
cent1 = ((t - 1) * hexb * 14) + 1
REM accounting for u-coordinate
cent1 = cent1 + (u * hexb)
cent2 = (chexa * 16) - (u * chexa * 1.5)
REM accounting for v-coordinate
cent1 = cent1 + (v * hexb)
cent2 = cent2 + (v * chexa * 1.5)
RETURN

600 REM draw hex
REM known=> cent1, cent2
REM from one o'clock clockwise
tmp1 = cent1
tmp2 = cent2 - chexa
tmp3 = cent1 + hexb
tmp4 = cent2 - (.5 * chexa)
LINE (tmp1, tmp2)-(tmp3, tmp4)
LINE -STEP(0, chexa)
LINE -STEP(-hexb, .5 * chexa)
LINE -STEP(-hexb, -.5 * chexa)
LINE -STEP(0, -chexa)
LINE -STEP(hexb, -.5 * chexa)
RETURN

650 REM fill hex w/ normal color
COLOR 1: GOSUB 600: REM draw hex in blue
PAINT (cent1, cent2), col%(FNhex(pt, pu, pv)), 1
RETURN

675 REM clear hex to grey
COLOR 8: GOSUB 600: REM draw hex in grey
PAINT (cent1, cent2), 0, 8
COLOR 1: GOSUB 600: REM draw hex in blue
RETURN

700 REM color menu
FOR i = 0 TO 15
   CIRCLE (i * 30 + 30, 400), 5, 15
   PAINT (i * 30 + 30, 400), i, 15
   x = i * 30 + 28: y = 413: word$ = (CHR$(i + 65))
   GOSUB 5100: REM draw menu letter
NEXT i
RETURN

750 REM quit/readme hint
x = 510: y = 400: word$ = "Q: Quit": GOSUB 5100
x = 510: y = 410: word$ = "R: Readme": GOSUB 5100
RETURN

800 REM make circle/cursor
GOSUB 545
CIRCLE (cent1, cent2), hexa / 2 + 1, 0
CIRCLE (cent1, cent2), hexa / 2 - 1, 0
CIRCLE (cent1, cent2), hexa / 2, 13
RETURN

805 REM display hex #
x = 10: y = 350
word$ = "Hex:" + STR$(FNhex(pt, pu, pv)) + " "
GOSUB 5100
RETURN

850 REM erase circle/cursor
GOSUB 545: REM get cent1/cent2
IF col%(FNhex(pt, pu, pv)) = 1 THEN
   GOSUB 675: REM clear hex
ELSE
   CIRCLE (cent1, cent2), hexa / 2, 0
END IF
GOSUB 650: REM fill hex
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

1000 REM load hexmap
OPEN "r", 1, f$
exist = LOF(1)
CLOSE 1
IF exist = 0 THEN
   SHELL "erase " + f$
   starthex = 245
END IF
IF exist = 0 THEN RETURN
OPEN "i", 1, f$
LINE INPUT #1, world$
FOR a = 1 TO 7
   LINE INPUT #1, tmp$
   FOR b = 1 TO 70
      c = ((a - 1) * 70) + b
      col%(c) = ASC(MID$(tmp$, b, 1)) - 65
   NEXT b
NEXT a
LINE INPUT #1, tmp$
starthex = VAL(RIGHT$(tmp$, LEN(tmp$) - 12))
a = 0
DO UNTIL EOF(1)
   a = a + 1
   LINE INPUT #1, tmp$
   place%(a) = VAL(LEFT$(tmp$, 3))
   c = INSTR(tmp$, ":")
   l = LEN(tmp$)
   IF c = 0 THEN
      name$(a, 1) = LTRIM$(RTRIM$(RIGHT$(tmp$, l - 4)))
      name$(a, 2) = ""
   ELSE
      name$(a, 1) = LTRIM$(RTRIM$(MID$(tmp$, 5, c - 5)))
      name$(a, 2) = LTRIM$(RTRIM$(RIGHT$(tmp$, l - c)))
   END IF
LOOP
CLOSE 1
numplace = a
RETURN

1050 REM save hexmap
OPEN "o", 1, f$
PRINT #1, world$
FOR a = 1 TO 7
   tmp$ = ""
   FOR b = 1 TO 70
      c = ((a - 1) * 70) + b
      tmp$ = tmp$ + CHR$(col%(c) + 65)
   NEXT b
   PRINT #1, tmp$
NEXT a
PRINT #1, "Start at hex"; FNhex(pt, pu, pv)
IF numplace <> 0 THEN
   FOR a = 1 TO numplace
      tmp$ = LTRIM$(STR$(place%(a)))
      IF LEN(tmp$) < 3 THEN tmp$ = "0" + tmp$
      IF LEN(tmp$) < 3 THEN tmp$ = "0" + tmp$
      tmp$ = tmp$ + " "
      tmp$ = tmp$ + name$(a, 1)
      IF name$(a, 2) <> "" THEN
         tmp$ = tmp$ + ":" + name$(a, 2)
      END IF
      PRINT #1, tmp$
   NEXT a
END IF
CLOSE 1
GOSUB 1100: REM erase status line
PRINT "Map Saved"
RETURN

1100 REM erase status line
LOCATE 28, 1: PRINT SPACE$(79)
LOCATE 28, 1: COLOR 11
RETURN

1200 REM draw location
GOSUB 500: REM get t/u/v
GOSUB 550: REM get cent1/cent2
x = cent1: y = cent2
LINE (x - 2, y - 2)-(x + 2, y + 2), 11, B
IF name$(np, 2) = "" THEN
   c = 9
ELSE
   c = 4
END IF
LINE (x - 1, y - 1)-(x + 1, y + 1), c, BF
x = cent1 + 5: y = cent2 + 5: word$ = name$(np, 1)
GOSUB 5100: REM draw word
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
RETURN

5200 REM calculate video stuff
xmost = 640
ymost = 500
REM screen aspect ratio
REM scar = 2.4
scar = (3 / 4) * (xmost / ymost)
REM hex radii
hexa = 10
hexb = INT((hexa ^ 2 - (.5 * hexa) ^ 2) ^ .5)
REM corrected for aspect ratio
chexa = hexa * scar
chexb = hexb
RETURN

5500 REM egacolor gold on blue
SCREEN 0
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
RETURN

5600 REM read colors.dat
OPEN "i", 1, "xtra\colors.dat"
FOR a = 1 TO 16
   LINE INPUT #1, tmp$
   l = LEN(tmp$)
   tmp$ = RIGHT$(tmp$, l - 4)
   colname$(a) = tmp$
NEXT a
CLOSE 1
RETURN

5700 REM read in settings
OPEN "i", 1, "gal.cfg"
INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
INPUT #1, t$: clrmode = VAL(RIGHT$(t$, 1))
CLOSE 1
RETURN

5800 REM set palette
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

10000 REM end
GOSUB 1050: REM save hexmap
10005 SCREEN 0: COLOR 7: CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email:  jimv@empirenet.com"
PRINT "             JimVassila@aol.com"
PRINT
PRINT "  Homepage:  http://members.aol.com/jimvassila"
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

