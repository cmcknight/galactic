 
REM Subsector Bitmapper v1.1
REM Public Domain 1997 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com
REM Written in Microsoft QuickBasic version 4.5
REM Making use of SAVESCR v0.6 by Aaron Zabudsky <zabudsk@ecf.utoronto.ca>

DECLARE SUB savescr (filename$, sx!, sy!, ex!, ey!, nbits!, imgnum!)

DIM subname$(16, 2)
DIM world$(80)
DIM basalg$(2, 50, 2)
DIM basalgn(2)
DIM algncol(50)
DIM letimage(13, 44) AS INTEGER
DIM length(44)
DIM jump%(300, 5)
DIM subtxt%(16)
DIM colors$(15)
DIM uwpstat$(15): REM stat names
DIM uwpnum(15): REM number of definitions per stat
DIM uwppos(15, 3): REM positions (main & mod) & color
DIM uwpdef$(15, 40): REM value definitions
DIM uwpval(15, 40, 2): REM low & high values for each def

DEF FNxstr$ (f21) = LTRIM$(STR$(f21))

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

DEF FNuwp$ (f2)
f3len = 1
IF uwpval(f2, 1, 1) > 1000 THEN f3len = 2
f3a$ = MID$(world$(ref), uwppos(f2, 1), f3len)
IF f3a$ = "" OR f3a$ = "  " THEN f3a$ = " "
f8 = LEN(world$(ref))
IF uwppos(f2, 2) <= f8 AND uwppos(f2, 2) <> 0 THEN
   f3b$ = MID$(world$(ref), uwppos(f2, 2), 1)
ELSE
   f3b$ = " "
END IF
f4a = FNnumber(f3a$)
f6$ = ""
FOR f5 = 1 TO uwpnum(f2)
   IF f4a >= uwpval(f2, f5, 1) AND f4a <= uwpval(f2, f5, 2) THEN
      f6$ = uwpdef$(f2, f5)
   END IF
NEXT f5
IF f6$ = "" THEN f6$ = "Unknown"
IF f3a$ = " " THEN f6$ = "Empty"
IF f3b$ <> " " THEN
   f7 = INSTR(f6$, "?")
   f8 = LEN(f6$)
   IF f7 = 1 THEN f6$ = f3b$ + RIGHT$(f6$, f8 - 1)
   IF f7 > 1 AND f8 = f7 THEN f6$ = LEFT$(f6$, f8 - 1) + f3b$
   IF f7 > 1 AND f8 <> f7 THEN
      f6a$ = LEFT$(f6$, f7 - 1)
      f6b$ = RIGHT$(f6$, f8 - f7)
      f6$ = f6a$ + f3b$ + f6b$
   END IF
END IF
FNuwp$ = f6$
END DEF

IF COMMAND$ <> "" GOTO 5
CLS : COLOR 11
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and it meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 900
GOTO 10000

5 REM startover
GOSUB 5700: REM read configuration
GOSUB 5000: REM read letters.dat -> image data
GOSUB 5200: REM calculate video stuff
GOSUB 2200: REM get sector info

100 REM get subsector
jumps = 0
FOR i = 1 TO 80
world$(i) = ""
NEXT i
OPEN "i", 1, fsub$
110 LINE INPUT #1, t4$
t4$ = LTRIM$(RTRIM$(t4$))
IF t4$ = "" GOTO 115
t3$ = LEFT$(t4$, 1)
IF (t3$ = "@" OR t3$ = "#") THEN GOTO 115
IF t3$ = "$" THEN
   jumps = jumps + 1
   rhex = VAL(MID$(t4$, 2, 4)): GOSUB 1100
   jump%(jumps, 1) = hex
   rhex = VAL(MID$(t4$, 7, 4)): GOSUB 1100
   jump%(jumps, 2) = hex
   jump%(jumps, 3) = VAL(MID$(t4$, 12, 2))
   place = 14
   IF jump%(jumps, 3) = -1 THEN place = place + 1
   jump%(jumps, 4) = VAL(MID$(t4$, place, 2))
   place = place + 2
   IF jump%(jumps, 4) = -1 THEN place = place + 1
   jump%(jumps, 5) = VAL(MID$(t4$, place, 2))
   IF jump%(jumps, 5) = 0 THEN jump%(jumps, 5) = 11
   GOTO 115
END IF
rhex = VAL(MID$(t4$, 15, 4))
GOSUB 1100
GOSUB 1150
world$(ref) = t4$
115 IF EOF(1) = -1 GOTO 120
GOTO 110
120 CLOSE 1

150 REM goto graphics mode
CLS
SCREEN 12
GOSUB 6000: REM set palette

151 REM draw subsector map
CLS
REM draw blue hexs
COLOR 1
FOR a = 1 TO 8
FOR b = 1 TO 10
hex = (a * 100) + b
GOSUB 500
NEXT b
NEXT a
REM draw jumproutes
IF jumps > 0 THEN
   FOR a = 1 TO jumps
      hex = jump%(a, 1): GOSUB 600
      p1 = cent1 + yank: p2 = cent2
      hex = jump%(a, 2): GOSUB 600
      p3 = cent1 + yank: p4 = cent2
      IF jump%(a, 3) <> 0 THEN
         p3 = p3 + (jump%(a, 3) * chexa * 12)
      END IF
      IF jump%(a, 4) <> 0 THEN
         p4 = p4 + (jump%(a, 4) * chexb * 20)
      END IF
      LINE (p1, p2)-(p3, p4), jump%(a, 5), , &H8888
   NEXT a
END IF
REM fill in map
FOR ref = 1 TO 80
IF LEN(world$(ref)) = 0 GOTO 155
l = ASC(MID$(world$(ref), 20, 1)) - 64
IF l = 24 THEN l = 6
GOSUB 1175
GOSUB 700
155 NEXT ref
REM subsector/sector name
COLOR 11
bottom$ = subname$ + "/" + secname$
l = LEN(bottom$)
LOCATE 29, 22 - INT(l / 2)
PRINT bottom$;

'Capture a picture
outfile$ = LEFT$(subfile$, LEN(subfile$) - 4) + ".bmp"

savescr outfile$, 0, 0, 339, 479, 4, 0
CLS : COLOR 11: LOCATE 5
PRINT
PRINT "Subsector map saved to "; outfile$
PRINT
PRINT "Hit any key to return to Galactic..."
GOSUB 900

END

500 REM plot a hex
GOSUB 600
REM known=> cent1, cent2
REM from one o'clock clockwise
tmp1 = cent1 + .5 * chexa + yank
tmp2 = cent2 - hexb
tmp3 = cent1 + chexa + yank
tmp4 = cent2
LINE (tmp1, tmp2)-(tmp3, tmp4)
LINE -STEP(-.5 * chexa, chexb)
LINE -STEP(-chexa, 0)
LINE -STEP(-.5 * chexa, -chexb)
LINE -STEP(.5 * chexa, -chexb)
LINE -STEP(chexa, 0)
RETURN

600 REM find center point of hex
REM in=> hex
REM out=> cent1, cent2
cent1 = hexa
cent2 = hexb
thex = hex - 101
610 IF thex < 99 GOTO 620
REM going across
cent1 = cent1 + 1.5 * hexa
thex = thex - 100
GOTO 610
620 IF thex = 0 GOTO 630
REM going down
cent2 = cent2 + 2 * hexb
thex = thex - 1
GOTO 620
630 REM correct for even columns
IF INT(hex / 100) MOD 2 = 1 THEN GOTO 640
cent2 = cent2 + hexb
640 REM correct for screen aspect ratio
cent1 = cent1 * scar
RETURN

700 REM plot starport
IF LEN(world$(ref)) = 0 THEN RETURN
tmp3$ = MID$(world$(ref), 65, 1)
tmp4 = 0: tmp5 = 0: noname = 0
IF tmp3$ = "h" THEN tmp4 = 1
IF tmp3$ = "H" THEN tmp4 = 2
IF RTRIM$(LEFT$(world$(ref), 14)) = "." THEN noname = 1
IF MID$(world$(ref), 20, 1) = "*" THEN
   tmp5 = VAL(MID$(world$(ref), 21, 1))
END IF
GOSUB 600: REM centerpoint
REM find allegiance
s$ = MID$(world$(ref), 56, 2)
FOR i2 = 1 TO basalgn(2)
   IF s$ = basalg$(2, i2, 1) THEN all = algncol(i2)
NEXT i2
REM draw marker
REM asteroids or circle
IF tmp5 = 0 THEN
   s$ = MID$(world$(ref), 21, 1)
   IF (s$ = "R" OR s$ = "0") AND tmp4 = 0 THEN
      x = cent1 + yank: y = cent2
      COLOR all
      PSET (x, y): PSET (x + 2, y + 2): PSET (x - 2, y - 2)
      PSET (x + 2, y - 2): PSET (x - 2, y + 2)
   ELSE
      PSET (cent1 + yank, cent2), 0
      CIRCLE (cent1 + yank, cent2), 3, all
      REM fill circle if there's any water
      IF MID$(world$(ref), 23, 1) <> "0" OR tmp4 <> 0 THEN
         PAINT (cent1 + yank, cent2), all
      END IF
   END IF
   REM gas giant & bases marker
   IF tmp4 = 0 THEN
      IF MID$(world$(ref), 54, 1) <> "0" THEN
         CIRCLE (cent1 + yank + 8, cent2 - 4), 1, all
         PSET (cent1 + yank + 8, cent2 - 4), all
      END IF
      IF MID$(world$(ref), 31, 1) <> " " THEN
         CIRCLE (cent1 + yank - 8, cent2 - 4), 1, all
         PSET (cent1 + yank - 8, cent2 - 4), all
      END IF
   END IF
END IF
REM nonworld markers
REM triangle
IF tmp5 = 1 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   PSET (x, y), 0
   LINE (x, y - 2)-(x + 2, y + 2), all
   LINE -STEP(-4, 0), all
   LINE -STEP(2, -4), all
   PAINT (x, y), all
END IF
REM square
IF tmp5 = 2 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   PSET (x, y), 0
   LINE (x - 2, y - 2)-(x + 2, y + 2), all, B
   PAINT (x, y), all
END IF
REM diamond
IF tmp5 = 3 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   PSET (x, y), 0
   LINE (x, y - 2)-(x + 2, y), all
   LINE -STEP(-2, 2), all
   LINE -STEP(-2, -2), all
   LINE -STEP(2, -2), all
   PAINT (x, y), all
END IF
REM lotsadots
IF tmp5 = 4 AND tmp4 < 2 THEN
   x = cent1 + yank: y = cent2
   COLOR all
   FOR x2 = -16 TO 16 STEP 4
      FOR y2 = -16 TO 16 STEP 4
         IF ABS(x2 * y2) < 192 THEN PSET (x + x2, y + y2)
      NEXT y2
   NEXT x2
END IF
REM zone
IF tmp4 < 2 OR tmp5 = 0 THEN
   s$ = MID$(world$(ref), 49, 1)
   IF s$ = "A" THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 1, 14
   END IF
   IF s$ = "R" THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 1, 12
   END IF
   IF s$ = "B" THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 1, 11
   END IF
END IF
REM newjump circle
IF newjump$ = MID$(world$(ref), 15, 4) AND newjf$ = fsub$ THEN
   CIRCLE (cent1 + yank, cent2), (hexa / 2), 5
   CIRCLE (cent1 + yank, cent2), (hexa / 2) + 4, 5
END IF
REM write name
word$ = RTRIM$(LEFT$(world$(ref), 14))
lenword = LEN(word$)
x = cent1 + yank - (lenword * 3) + 1
y = cent2 + 10
IF tmp4 < 2 AND noname = 0 THEN GOSUB 5100
REM write starport
word$ = MID$(world$(ref), 20, 1)
x = cent1 + yank - 2: y = cent2 - 5
IF tmp4 = 0 AND word$ <> "*" THEN GOSUB 5100
RETURN

800 REM make circle
GOSUB 600
CIRCLE (cent1 + yank, cent2), hexa / 2, 13
RETURN

850 REM erase circle
GOSUB 600
CIRCLE (cent1 + yank, cent2), hexa / 2, 0
GOSUB 700
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

1150 REM convert map hex to ref#
REM in -> hex
REM out -> ref
t1 = INT(hex / 100)
t2 = hex - t1 * 100
ref = (t1 - 1) * 10 + t2
RETURN

1175 REM convert ref# to map hex
REM in -> ref
REM out -> hex
t1 = INT((ref + 9) / 10)
t2 = ref MOD 10
IF t2 = 0 THEN t2 = 10
hex = t1 * 100 + t2
RETURN

2200 REM get sector data
f$ = secfile$
OPEN "i", 1, f$
LINE INPUT #1, secname$
LINE INPUT #1, temp$
FOR i = 1 TO 16
   LINE INPUT #1, temp$
   tmp1$ = RTRIM$(MID$(temp$, 4, 26))
   tmp2$ = RTRIM$(MID$(temp$, 30, 12))
   IF subfile$ = tmp2$ THEN subname$ = tmp1$
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
COLOR 15: GOSUB 5005
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
xunder = x: yunder = y + 6
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
REM underline if hi pop world
hipop = FNnumber(MID$(world$(ref), 24, 1))
IF hipop >= 9 AND l > 1 AND nonworld = 0 THEN
   LINE (xunder, yunder)-(x - 2, yunder), 15
END IF
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
yank = 20
zi = 1
zj = 1
RETURN

5500 REM egacolor gold on blue
SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
RETURN

5700 REM read in settings
OPEN "i", 1, "gal.cfg"
INPUT #1, t$: l = LEN(t$)
editor$ = RIGHT$(t$, l - 7)
INPUT #1, t$: l = LEN(t$)
reader$ = RIGHT$(t$, l - 7)
INPUT #1, t$: clrmode = VAL(RIGHT$(t$, 1))
CLOSE 1
c$ = RTRIM$(LCASE$(COMMAND$))
fsub$ = c$
c$ = RIGHT$(c$, LEN(c$) - 5)
a = INSTR(c$, "\")
galdir0$ = LEFT$(c$, a - 1)
galdir$ = "gals\" + galdir0$
c$ = RIGHT$(c$, LEN(c$) - a)
a = INSTR(c$, "\")
secdir$ = LEFT$(c$, a - 1)
l = LEN(secdir$)
seclist$ = galdir$ + "\" + galdir0$ + ".lst"
secfile$ = galdir$ + "\" + secdir$ + "\" + secdir$ + ".dat"
c$ = RIGHT$(c$, LEN(c$) - a - 4)
subfile$ = c$
REM sector list
OPEN "i", 1, seclist$
INPUT #1, t$
INPUT #1, t$
DO UNTIL EOF(1)
   INPUT #1, t$
   t$ = RTRIM$(LEFT$(t$, 50))
   IF t$ = "" GOTO 5705
   IF LEFT$(t$, l + 1) = secdir$ + " " THEN
      secname$ = RIGHT$(t$, LEN(t$) - 13)
   END IF
5705 LOOP
CLOSE 1
RETURN

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

10000 REM end
COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email: jimv@empirenet.com"
PRINT "            jimvassila@aol.com"
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

