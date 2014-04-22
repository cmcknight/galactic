
REM Sector Map v1.1
REM Freeware 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com
REM Written in Microsoft QuickBasic version 4.5
REM Includes SAVESCR v0.6 by Aaron Zabudsky <zabudsk@ecf.utoronto.ca>

DECLARE SUB savescr (filename$, sx!, sy!, ex!, ey!, nbits!, imgnum!)

DIM subname$(16, 2)
DIM world$(80)
DIM basalg$(2, 50, 2)
DIM basalgn(2)
DIM algncol(50)
DIM subtxt%(16)

IF COMMAND$ <> "" GOTO 4
CLS : COLOR 11
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 900
GOTO 10000

4 tog1 = 1: tog2 = 1: tog3 = 1
5 REM startover
GOSUB 5700: REM read configuration
GOSUB 5200: REM calculate video stuff
GOSUB 2200: REM read sector file

SCREEN 12
GOSUB 5800: REM set palette
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

OPEN "i", 2, galdir$ + "\" + galdir0$ + ".lst"
INPUT #2, t$
INPUT #2, t$
DO UNTIL EOF(2)
 LINE INPUT #2, t$
 IF RTRIM$(LEFT$(t$, 8)) = dir0$ THEN
  wherex = VAL(MID$(t$, 51, 4))
  wherey = VAL(MID$(t$, 56, 4))
 END IF
LOOP
CLOSE 2

OPEN "o", 2, galdir$ + "\where.dat"
PRINT #2, wherex
PRINT #2, wherey
CLOSE 2

north$ = "<nil>"
south$ = "<nil>"
east$ = "<nil>"
west$ = "<nil>"
OPEN "i", 2, galdir$ + "\" + galdir0$ + ".lst"
INPUT #2, t$
INPUT #2, t$
DO UNTIL EOF(2)
 LINE INPUT #2, t$
 tmpx = VAL(MID$(t$, 51, 4))
 tmpy = VAL(MID$(t$, 56, 4))
 dude$ = RTRIM$(LEFT$(t$, 8))
 IF MID$(t$, 61, 1) = "I" THEN dude$ = "<nil>"
 IF tmpx = wherex + 1 AND tmpy = wherey THEN east$ = dude$
 IF tmpx = wherex - 1 AND tmpy = wherey THEN west$ = dude$
 IF tmpx = wherex AND tmpy = wherey + 1 THEN south$ = dude$
 IF tmpx = wherex AND tmpy = wherey - 1 THEN north$ = dude$
LOOP
CLOSE 2

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

5200 REM calculate video stuff
xmost = 640
ymost = 500
REM screen aspect ratio
REM scar = 2.4
scar = (3 / 4) * (xmost / ymost)
REM hex radii
hexa = 25
hexb = INT((hexa ^ 2 - (.5 * hexa) ^ 2) ^ .5)
REM corrected for aspect ratio
chexa = hexa * scar
chexb = hexb
REM yank right
yank = xmost - INT(chexa * 1.5 * 8.3333) - 22
zi = 1
zj = 1
RETURN

5500 REM egacolor gold on blue
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
RETURN

5700 REM read in settings
OPEN "i", 1, "gal.cfg"
INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
INPUT #1, t$: clrmode = VAL(RIGHT$(t$, 1))
CLOSE 1
c$ = LCASE$(COMMAND$)
c$ = RIGHT$(c$, LEN(c$) - 5)
a = INSTR(c$, "\")
lc = LEN(c$)
galdir0$ = LEFT$(c$, a - 1)
galdir$ = "gals\" + galdir0$
l = LEN(galdir$)
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
          secname2$ = RTRIM$(MID$(t$, 14, 37))
       END IF
    END IF
 LOOP
 CLOSE 1
END IF
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

6000 REM graphical sector
CLS
REM plot hexes
COLOR 1
FOR c1 = 1 TO 32
 FOR c2 = 1 TO 40
  GOSUB 6200: REM center
  GOSUB 6250: REM hex
 NEXT c2
NEXT c1

REM plot jump routes
IF tog1 = 0 GOTO 6060
FOR a = 1 TO 16
 fsub$ = mapdir$ + subname$(a, 2)
 OPEN "i", 1, fsub$
 DO UNTIL EOF(1)
  LINE INPUT #1, t$
  IF LEN(t$) = 0 GOTO 6050
  IF LEFT$(t$, 1) <> "$" GOTO 6050
  rhex = VAL(MID$(t$, 2, 4)): GOSUB 1100
  j1 = hex
  rhex = VAL(MID$(t$, 7, 4)): GOSUB 1100
  j2 = hex
  j3 = VAL(MID$(t$, 12, 2))
  place = 14
  IF j3 = -1 THEN place = place + 1
  j4 = VAL(MID$(t$, place, 2))
  place = place + 2
  IF j4 = -1 THEN place = place + 1
  j5 = VAL(MID$(t$, place, 2))
  IF j5 = 0 THEN j5 = 11
  c1 = INT(j1 / 100) + (((a - 1) MOD 4) * 8)
  c2 = j1 - (INT(j1 / 100) * 100) + (INT((a - 1) / 4) * 10)
  GOSUB 6200: REM center
  d1 = cent1: d2 = cent2
  c1 = INT(j2 / 100) + (((a - 1) MOD 4) * 8) + (j3 * 8)
  c2 = j2 - (INT(j2 / 100) * 100) + (INT((a - 1) / 4) * 10) + (j4 * 10)
  GOSUB 6200: REM center
  d3 = cent1 + 1: d4 = cent2 + 1
  LINE (d1, d2)-(d3, d4), j5, , &H5555
6050 LOOP
 CLOSE 1
NEXT a

6060 REM plot stars
FOR a = 1 TO 16
 fsub$ = mapdir$ + subname$(a, 2)
 OPEN "i", 1, fsub$
 DO UNTIL EOF(1)
  LINE INPUT #1, t$
  IF LEN(t$) = 0 GOTO 6090
  IF INSTR("@#$", LEFT$(t$, 1)) <> 0 GOTO 6090
  c$ = MID$(t$, 15, 4)
  c1 = VAL(LEFT$(c$, 2))
  c2 = VAL(RIGHT$(c$, 2))
  s$ = MID$(t$, 56, 2)
  FOR i2 = 1 TO basalgn(2)
   IF s$ = basalg$(2, i2, 1) THEN all = algncol(i2)
  NEXT i2
  GOSUB 6200: REM center
  tmp14 = 0: tmp15 = 0
  IF MID$(t$, 65, 1) = "h" THEN tmp14 = 1
  IF MID$(t$, 65, 1) = "H" THEN tmp14 = 2
  IF MID$(t$, 20, 1) = "*" THEN tmp15 = VAL(MID$(t$, 21, 1))
  IF tmp15 = 0 OR tmp14 < 2 THEN PSET (cent1 + 1, cent2), all
  IF tmp15 = 0 THEN CIRCLE (cent1 + 1, cent2), 1, all
  IF tmp15 = 4 AND tmp14 < 2 THEN
   COLOR all
   x = cent1 + 1: y = cent2
   PSET (x - 2, y - 2): PSET (x - 2, y + 2)
   PSET (x + 2, y - 2): PSET (x + 2, y + 2)
  END IF
  IF MID$(t$, 63, 1) = "f" OR MID$(t$, 63, 1) = "m" THEN
   IF tog2 = 1 THEN
    COLOR 4: GOSUB 6250: REM hex
   END IF
  END IF
  IF tog3 = 0 GOTO 6090
  IF tmp14 = 2 AND tmp15 > 0 GOTO 6090
  IF MID$(t$, 49, 1) = "A" THEN CIRCLE (cent1 + 1, cent2), 3, 14
  IF MID$(t$, 49, 1) = "R" THEN CIRCLE (cent1 + 1, cent2), 3, 12
  IF MID$(t$, 49, 1) = "B" THEN CIRCLE (cent1 + 1, cent2), 3, 11
6090 LOOP
 CLOSE 1
NEXT a
COLOR 14
LOCATE 2, 40: PRINT "Sector: "; secname$
COLOR 11
FOR a = 1 TO 16
 LOCATE 3 + a, 43
 PRINT "Subsector ";
 PRINT CHR$(a + 64); ": "; subname$(a, 1)
NEXT a
COLOR 13
LOCATE 21, 40: PRINT "Jump Routes:      ";
IF tog1 = 0 THEN PRINT "Not ";
PRINT "Showing"
LOCATE 22, 40: PRINT "Red Hexes:        ";
IF tog2 = 0 THEN PRINT "Not ";
PRINT "Showing"
LOCATE 23, 40: PRINT "Red/Amber Zones:  ";
IF tog3 = 0 THEN PRINT "Not ";
PRINT "Showing"
LOCATE 30, 70: COLOR 12: PRINT "? = Help";
6095 GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 1 AND k1 = 72 THEN GOSUB 6110: REM up
IF k2 = 0 AND k1 = 75 THEN GOSUB 6110: REM k
IF k2 = 1 AND k1 = 80 THEN GOSUB 6120: REM down
IF k2 = 0 AND k1 = 74 THEN GOSUB 6120: REM j
IF k2 = 1 AND k1 = 75 THEN GOSUB 6130: REM left
IF k2 = 0 AND k1 = 72 THEN GOSUB 6130: REM h
IF k2 = 1 AND k1 = 77 THEN GOSUB 6140: REM right
IF k2 = 0 AND k1 = 76 THEN GOSUB 6140: REM l
IF k2 = 0 AND k1 = 27 GOTO 10000: REM esc
IF k2 = 0 AND k1 = 81 GOTO 10000: REM q
IF k2 = 0 AND k1 = 63 GOTO 6150: REM ?
IF k2 = 0 AND k1 = 49 GOTO 6100: REM 1
IF k2 = 0 AND k1 = 50 GOTO 6102: REM 2
IF k2 = 0 AND k1 = 51 GOTO 6104: REM 3
IF k2 = 1 AND k1 = 68 GOTO 6300: REM F10
GOTO 6095
6100 REM 1 / toggle jumproutes
tog1 = tog1 + 1: IF tog1 = 2 THEN tog1 = 0
GOTO 6000
6102 REM 2 / toggle redhexes
tog2 = tog2 + 1: IF tog2 = 2 THEN tog2 = 0
GOTO 6000
6104 REM 3 / toggle zonage
tog3 = tog3 + 1: IF tog3 = 2 THEN tog3 = 0
GOTO 6000
6110 REM up
IF north$ = "<nil>" THEN GOTO 6095
dir$ = north$: wherey = wherey - 1: GOSUB 5710: GOSUB 2200: GOTO 6000
6120 REM down
IF south$ = "<nil>" THEN GOTO 6095
dir$ = south$: wherey = wherey + 1: GOSUB 5710: GOSUB 2200: GOTO 6000
6130 REM left
IF west$ = "<nil>" THEN GOTO 6095
dir$ = west$: wherex = wherex - 1: GOSUB 5710: GOSUB 2200: GOTO 6000
6140 REM right
IF east$ = "<nil>" THEN GOTO 6095
dir$ = east$: wherex = wherex + 1: GOSUB 5710: GOSUB 2200: GOTO 6000
6150 REM graphical sector page commands list
SCREEN 0: COLOR 7: CLS : PRINT "."
GOSUB 5500: REM egacolor
SHELL reader$ + " help\gsec-cmd.txt"
SCREEN 12: GOTO 6000

6200 REM center
cent1 = c1 * 8 + INT((c1 - 1) / 8)
cent2 = c2 * 10 + INT((c2 - 1) / 10)
IF c1 MOD 2 = 0 THEN cent2 = cent2 + 5
RETURN

6250 REM plot hex from one o'clock clockwise
tmp1 = cent1 + 4: tmp2 = cent2 - 5
tmp3 = cent1 + 6: tmp4 = cent2
LINE (tmp1, tmp2)-(tmp3, tmp4)
LINE -STEP(-2, 5)
LINE -STEP(-6, 0)
LINE -STEP(-2, -5)
LINE -STEP(2, -5)
LINE -STEP(6, 0)
RETURN

6300 REM save screen
outfile$ = dir0$ + ".bmp"
horiz = 18 - (LEN(secname$) / 2)
IF horiz < 1 THEN horiz = 1
LOCATE 28, horiz: COLOR 11
PRINT secname$;
savescr outfile$, 0, 0, 269, 449, 4, 0
SCREEN 0: CLS : LOCATE 5: COLOR 11
PRINT
PRINT "Sector map saved to "; outfile$
PRINT
PRINT "Hit any key to continue..."
PRINT
GOSUB 900
SCREEN 12: GOTO 6000

10000 REM end
COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email: jimv@empirenet.com"
PRINT "            JimVassila@aol.com"
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

