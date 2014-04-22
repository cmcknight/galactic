DECLARE SUB SetPlot (plot$, x%, y%)
DECLARE FUNCTION IsPlot% (plot$, x%, y%)
DECLARE FUNCTION pow2% (expn%)
DECLARE SUB PlotSectorGrid (x%, y%, ox%, oy%, gx%, gy%, scale%)
DECLARE FUNCTION FindSector% (x%, y%)
DECLARE FUNCTION FindSecName$ (x%, y%)
DECLARE FUNCTION ReadSector% (x%, y%, into%)
DECLARE FUNCTION LookupSector$ (x%, y%)
DECLARE SUB ReadSubsector (fsub$, plot$)
DECLARE SUB PlotSector (ox%, oy%, sec%, scale%)

REM Galaxy Map v1.0
REM Freeware 1997 Jo Grant
REM Dublin, Ireland
REM jaymin@maths.tcd.ie
REM Written in Microsoft QuickBasic version 4.5
REM Includes SAVESCR v0.6 by Aaron Zabudsky <zabudsk@ecf.utoronto.ca>

DECLARE SUB savescr (filename$, sx!, sy!, ex!, ey!, nbits!, imgnum!)

REM Global shared variables
DIM SHARED galdir$, gallst$
DIM SHARED SecName$(64), SecFile$(64), SecPlot$(64), SecQueries%(64)
DIM SHARED Secx%(64), Secy%(64)
DIM SHARED numsectors%, querylog%, cachesize%
DIM SHARED focusx%, focusy%, focnum%

REM global variables
DIM subname$(16, 2)
DIM world$(80)
DIM basalg$(2, 50, 2)
DIM basalgn(2)
DIM algncol(50)
DIM subtxt%(16)
DIM mapscale%

REM IF COMMAND$ <> "" GOTO 4
GOTO 4
CLS : COLOR 11
PRINT "This program is not meant to be run as a stand-alone"
PRINT "piece of software. It is part of the 'Galactic' package,"
PRINT "and is meant to be executed from gal.exe."
PRINT
PRINT "Hit any key to Exit"
GOSUB 900
GOTO 10000

4 numsectors% = 0: querylog% = 1: cachesize% = 64: mapscale% = 1
5 REM startover
GOSUB 5700: REM read configuration
GOSUB 5200: REM calculate video stuff

SCREEN 12
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
f$ = dir$ + SecFile$
OPEN "i", 1, f$
LINE INPUT #1, SecName$
LINE INPUT #1, temp$
FOR i = 1 TO 16
LINE INPUT #1, temp$
t9 = LEN(temp$)
subtxt%(i) = 0
IF MID$(temp$, 50, 1) = "f" THEN subtxt%(i) = 1
IF MID$(temp$, 50, 1) = "m" THEN subtxt%(i) = 2
subname$(i, 1) = RTRIM$(MID$(temp$, 4, 26))
subname$(i, 2) = RTRIM$(MID$(temp$, 30, 12))
PRINT subname$(i, 1), subname$(i, 2)
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
REM Global settings
fd% = FREEFILE
OPEN "gal.cfg" FOR INPUT AS fd%
INPUT #fd%, t$: l = LEN(t$): editor$ = RIGHT$(t$, l - 7)
INPUT #fd%, t$: l = LEN(t$): reader$ = RIGHT$(t$, l - 7)
CLOSE fd%
REM Command line contains path to galaxy
galdir$ = LCASE$(COMMAND$)
REM work out galaxy.lst file
o% = INSTR(galdir$, "\")
gallst$ = galdir$ + "\" + MID$(galdir$, o% + 1) + ".lst"
REM Current Focus settings
fd% = FREEFILE
OPEN galdir$ + "\where.dat" FOR INPUT AS fd%
INPUT #fd%, t$: focusx% = VAL(t$)
INPUT #fd%, t$: focusy% = VAL(t$)
CLOSE #fd%

5710 REM read in sector particulars
focnum% = FindSector(focusx%, focusy%)
RETURN

6000 REM graphical sector
CLS
6060 REM plot stars
  IF mapscale% = 1 THEN
    PlotSectorGrid focusx%, focusy%, 1, 1, 6, 3, 1
  ELSE
    PlotSectorGrid focusx%, focusy%, 1, 1, 18, 9, 2
  END IF
  COLOR 11
  LOCATE 24, 3: PRINT "Centerpoint: " + FindSecName$(focusx%, focusy%)
  LOCATE 25, 70: COLOR 13: PRINT "? = Help"
  COLOR 11
  'LOCATE 24, 33: PRINT "N: " + FindSecName$(focusx%, focusy% - 1)
  'LOCATE 25, 33: PRINT "S: " + FindSecName$(focusx%, focusy% + 1)
  'LOCATE 24, 53: PRINT "E: " + FindSecName$(focusx% + 1, focusy%)
  'LOCATE 25, 53: PRINT "W: " + FindSecName$(focusx% - 1, focusy%)
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
IF k2 = 0 AND k1 = 83 GOTO 6155: REM s
IF k2 = 0 AND k1 = 63 GOTO 6150: REM ?
IF k2 = 1 AND k1 = 68 GOTO 6300: REM F10
GOTO 6095
6110 REM up
focusy% = focusy% - 1: GOTO 6145
6120 REM down
focusy% = focusy% + 1: GOTO 6145
6130 REM left
focusx% = focusx% - 1: GOTO 6145
6140 REM right
focusx% = focusx% + 1: GOTO 6145
6145 REM shift focus
focnum% = FindSector(focusx%, focusy%): GOTO 6000

6150 REM graphical sector page commands list
SCREEN 0: COLOR 7: CLS : PRINT "."
GOSUB 5500: REM egacolor
SHELL reader$ + " help\gmap.txt"
SCREEN 12: GOTO 6000

6155 REM toggle scale
IF mapscale% = 1 THEN
  mapscale% = 2
ELSE
  mapscale% = 1
END IF
GOTO 6000

6300 REM save screen
outfile$ = SecFile$(focnum%) + ".bmp"
horiz = 18 - (LEN(SecName$(focnum%)) / 2)
IF horiz < 1 THEN horiz = 1
LOCATE 28, horiz: COLOR 11
PRINT SecName$;
savescr outfile$, 0, 0, 639, 479, 4, 0
SCREEN 0: CLS : LOCATE 5: COLOR 11
PRINT
PRINT "Sector map saved to "; outfile$
PRINT
PRINT "Hit any key to continue..."
PRINT
GOSUB 900
SCREEN 12: GOTO 6000

10000 REM end
REM save where
fd% = FREEFILE
OPEN galdir$ + "\where.dat" FOR OUTPUT AS fd%
PRINT #fd%, STR$(focusx%)
PRINT #fd%, STR$(focusy%)
CLOSE #fd%

COLOR 7
CLS
PRINT
PRINT "For Assistance and/or Snide Remarks:"
PRINT
PRINT "     Email: jaymin@maths.tcd.ie (Jo)"
PRINT "         or jimv@empirenet.com (Jim)"
END

FUNCTION FindSecName$ (x%, y%)
  FOR i% = 0 TO numsectors% - 1
    IF Secx%(i%) = x% AND Secy%(i%) = y% THEN
      FindSecName$ = SecName$(i%)
      EXIT FUNCTION
    END IF
  NEXT i%
  FindSecName$ = STR$(x%) + "," + STR$(y%)
END FUNCTION

FUNCTION FindSector% (x%, y%)
  REM This is the base function for retreiving sectors. For speed we
  REM cache a number of sectors. The first thing we do is search the
  REM cache for the sector. If found, we return immediately. If not
  REM we check to see if there is any space left in the cache. If so,
  REM we read the new sector in. If not, we search the cache for the
  REM oldest referenced sector, and overwrite it.
  REM Each time we reference a sector we update the query number to
  REM a sequentially increasing value. We can then use this later to
  REM determine the sector that hasn't been referenced the longest by
  REM just looking for the lowest number.

  REM first see if already loaded
  FOR i% = 0 TO numsectors% - 1
    IF Secx%(i%) = x% AND Secy%(i%) = y% THEN
      SecQueries%(i%) = querylog%
      querylog% = querylog% + 1
      FindSector% = i%
      EXIT FUNCTION
    END IF
  NEXT i%
  REM Second read into cache if there is space
  IF numsectors% <= cachesize% THEN
    bestsec% = ReadSector(x%, y%, numsectors%)
    IF bestsec% >= 0 THEN numsectors% = numsectors% + 1
    FindSector% = bestsec%
    EXIT FUNCTION
  END IF
  REM Thrid Find least recently used and zap
  bestsec% = 0
  FOR i% = 1 TO numsectors% - 1
    IF SecQueries%(i%) < SecQueries%(bestsec%) THEN
      bestsec% = i%
    END IF
  NEXT i%
  REM Read into oldest
  bestsec% = ReadSector(x%, y%, bestsec%)
  IF bestsec% >= 0 THEN
    SecQueries%(bestsec%) = querylog%
    querylog% = querylog% + 1
  END IF
  FindSector% = bestsec%
END FUNCTION

FUNCTION IsPlot% (plot$, x%, y%)
  REM The Plot$ is used to maintain a list of chars that is, in fact, a
  REM bitfield containing the on-off state for all hexes in a sector.
  REM There wasn't enough string space to do it on a byte level so we
  REM had to do it this way.
  REM Here, we check to see if hex x,y is set and return 0 or 1 accordingly.
  offset% = (x% - 1) + (y% - 1) * 32
  byteoffset% = INT(offset% / 8) + 1
  bitoffset% = (offset% MOD 8)
  byte$ = MID$(plot$, byteoffset%, 1)
  mask% = pow2(bitoffset%)
  bval% = ASC(byte$)
  IF (bval% AND mask%) = 0 THEN
    IsPlot% = 0
  ELSE
    IsPlot% = 1
  END IF
END FUNCTION

FUNCTION LookupSector$ (x%, y%)
  LookupSector$ = ""
  fd% = FREEFILE
  OPEN gallst$ FOR INPUT AS fd%
  INPUT #fd%, t$
  INPUT #fd%, t$
  DO WHILE NOT EOF(fd%)
    INPUT #fd%, t$
    xx% = VAL(MID$(t$, 51, 4))
    yy% = VAL(MID$(t$, 56, 4))
    seccol% = ASC(MID$(t$, 61, 1)) - 65
    IF xx% = x% AND yy% = y% AND seccol% <> 8 THEN
      LookupSector$ = RTRIM$(LEFT$(t$, 12))
      EXIT DO
    END IF
  LOOP
  CLOSE fd%
END FUNCTION

SUB PlotSector (ox%, oy%, sec%, scale%)
  REM Given the offset and sector reference, we get the sector
  REM and draw it on the screen.
  plot$ = SecPlot$(sec%)
  IF sec$ = focus$ THEN
    COLOR 15
  ELSE
    COLOR 7
  END IF
  FOR y% = 1 TO 40
    FOR x% = 1 TO 32
      IF IsPlot%(plot$, x%, y%) <> 0 THEN
        IF scale% = 1 THEN
          x1% = x% * 3 + ox%: y1% = y% * 3 + oy%
          IF x% MOD 2 = 0 THEN y1% = y1% + 1
          PSET (x1%, y1%): PSET (x1% + 1, y1%)
          PSET (x1%, y1% + 1): PSET (x1% + 1, y1% + 1)
        ELSEIF scale% = 2 THEN
          x1% = x% + ox%: y1% = y% + oy%
          PSET (x1%, y1%)
        END IF
      END IF
    NEXT x%
  NEXT y%
END SUB

SUB PlotSectorGrid (xx%, yy%, ox%, oy%, gx%, gy%, scale%)
  REM This does the whole business of working out the grid of sectors
  REM (for the given size) and drawing all of them on the screen.
  DIM SecGrid$(gx%, gy%)
  basex% = -(gx% / 2)
  basex% = basex% + xx%
  basey% = -(gy% / 2)
  basey% = basey% + yy%
  FOR y% = 1 TO gy%
    FOR x% = 1 TO gx%
      o% = FindSector(basex% + x%, basey% + y%)
      IF o% >= 0 THEN
        IF scale% = 1 THEN
          PlotSector ox% + 32 * 3 * (x% - 1), oy% + (40 * 3 - 1) * (y% - 1), o%, scale%
        ELSE
          PlotSector ox% + 32 * (x% - 1), oy% + 40 * (y% - 1), o%, scale%
        END IF
      END IF
    NEXT x%
  NEXT y%
END SUB

FUNCTION pow2% (expn%)
  REM Claculate 2 to the power of expn% For masking,
  SELECT CASE expn%
    CASE 0
      pow2% = 1
    CASE 1
      pow2% = 2
    CASE 2
      pow2% = 4
    CASE 3
      pow2% = 8
    CASE 4
      pow2% = 16
    CASE 5
      pow2% = 32
    CASE 6
      pow2% = 64
    CASE 7
      pow2% = 128
    END SELECT
END FUNCTION

FUNCTION ReadSector% (x%, y%, into%)
  SecFil$ = LookupSector(x%, y%)
  IF SecFil$ = "" THEN
    ReadSector% = -1
    EXIT FUNCTION
  END IF
  Secx%(into%) = x%
  Secy%(into%) = y%
  REM Read a sector from the disk into the given place in the cache.
  SecFile$(into%) = SecFil$
  dir$ = galdir$ + "\" + SecFil$ + "\"
  f$ = dir$ + SecFil$ + ".dat"
  fd% = FREEFILE
  OPEN f$ FOR INPUT AS fd%
  LINE INPUT #fd%, SecName$(into%)
  LINE INPUT #fd%, temp$
  plot$ = STRING$(160, CHR$(0))
  FOR i = 1 TO 16
    LINE INPUT #fd%, temp$
    subname$ = RTRIM$(MID$(temp$, 30, 12))
    ReadSubsector galdir$ + "\" + SecFil$ + "\MAP\" + subname$, plot$
  NEXT i
  SecPlot$(into%) = plot$
  CLOSE fd%
  ReadSector% = into%
END FUNCTION

SUB ReadSubsector (fsub$, plot$)
  REM Read an individual subsector and set the values in the plot
  REM accordingly.
  fd% = FREEFILE
  OPEN "i", fd%, fsub$
  DO UNTIL EOF(fd%)
    LINE INPUT #fd%, t$
    t$ = LTRIM$(RTRIM$(t$))
    IF t$ <> "" THEN
     IF (INSTR("@#$", LEFT$(t$, 1)) = 0) THEN
      c$ = MID$(t$, 15, 4)
      c1% = VAL(LEFT$(c$, 2))
      c2% = VAL(RIGHT$(c$, 2))
      IF (c1% < 1) OR (c1% > 32) OR (c2% < 1) OR (c2% > 40) THEN
        PRINT "Erronious line in " + fsub$
        PRINT t$
      END IF
      SetPlot plot$, c1%, c2%
     END IF
    END IF
  LOOP
  CLOSE fd%
END SUB

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

SUB SetPlot (plot$, x%, y%)
  REM The Plot$ is used to maintain a list of chars that is, in fact, a
  REM bitfield containing the on-off state for all hexes in a sector.
  REM There wasn't enough string space to do it on a byte level so we
  REM had to do it this way.
  REM Here, we set the bit for hex x,y
  offset% = (x% - 1) + (y% - 1) * 32
  byteoffset% = INT(offset% / 8) + 1
  bitoffset% = (offset% MOD 8)
  byte$ = MID$(plot$, byteoffset%, 1)
  mask% = pow2(bitoffset%)
  bval% = ASC(byte$)
  bval% = bval% + mask%
  plot$ = LEFT$(plot$, byteoffset% - 1) + CHR$(bval%) + MID$(plot$, byteoffset% + 1)
END SUB

