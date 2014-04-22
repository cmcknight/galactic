
' Gal23 -> Gal24 Galaxies Conversion Program
' Jim Vassilakos (1998)
' jimv@empirenet.com

DIM galdir$(100)
DIM galname$(100)
i = 0

OPEN "i", 1, "gal.lst"
LINE INPUT #1, t$
LINE INPUT #1, t$
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   t$ = RTRIM$(LTRIM$(t$))
   IF t$ = "" GOTO 100
   i = i + 1
   galdir$(i) = RTRIM$(LEFT$(t$, 8))
   galname$(i) = LEFT$(t$, LEN(t$) - 13)
100 LOOP
CLOSE 1
numgals = i

REM make gals directory
SHELL "mkdir gals"
OPEN "o", 1, "gals\where.dat"
PRINT #1, galdir$(1)
CLOSE 1

REM copy galaxies to gals
FOR a = 1 TO numgals
 SHELL "mkdir gals\" + galdir$(a)
 s$ = "xcopy " + galdir$(a) + "\*.* gals\" + galdir$(a) + " /e /v"
 SHELL s$
 OPEN "o", 1, "gals\" + galdir$(a) + "\where.dat"
 PRINT #1, 0
 PRINT #1, 0
 CLOSE 1
NEXT a

REM revise sector lists
FOR a = 1 TO numgals
 seclist$ = "gals\" + galdir$(a) + "\" + galdir$(a) + ".lst"
 PRINT seclist$
 SHELL "copy " + seclist$ + " tmp.tmp"
 OPEN "i", 1, "tmp.tmp"
 OPEN "o", 2, seclist$
 LINE INPUT #1, t$
 PRINT #2, t$
 LINE INPUT #1, t$
 PRINT #2, STRING$(61, "-")
 b = -1
 DO UNTIL EOF(1)
  LINE INPUT #1, t$
  t$ = LTRIM$(RTRIM$(t$))
  IF t$ = "" GOTO 200
  b = b + 1
  l = LEN(t$)
  t$ = t$ + SPACE$(50 - l)
  t$ = t$ + LTRIM$(RTRIM$(STR$(b)))
  l = LEN(t$)
  t$ = t$ + SPACE$(55 - l) + "0    K"
  PRINT #2, t$
200 LOOP
CLOSE
NEXT a

REM create list of menu files
SHELL "dir gals /s /b > tmp.tmp"
OPEN "i", 1, "tmp.tmp"
OPEN "o", 2, "tmp2.tmp"
DO UNTIL EOF(1)
 LINE INPUT #1, t$
 t$ = LCASE$(RTRIM$(LTRIM$(t$)))
 IF t$ = "" GOTO 300
 IF RIGHT$(t$, 4) = ".mnu" THEN PRINT #2, t$
300 LOOP
CLOSE
SHELL "del tmp.tmp"

REM revise menu files
OPEN "i", 1, "tmp2.tmp"
DO UNTIL EOF(1)
 LINE INPUT #1, f$
 PRINT f$
 SHELL "copy " + f$ + " tmp.tmp"
 OPEN "i", 2, "tmp.tmp"
 OPEN "o", 3, f$
 DO UNTIL EOF(2)
  LINE INPUT #2, t$
  IF LEFT$(t$, 5) = "@dir=" THEN
   u$ = RIGHT$(t$, LEN(t$) - 5)
   t$ = "@dir=gals\" + u$
  END IF
  PRINT #3, t$
 LOOP
 CLOSE 2
 CLOSE 3
 SHELL "del tmp.tmp"
400 LOOP
CLOSE 1

SHELL "del tmp2.tmp"

REM revise sector data files
FOR a = 1 TO numgals
 seclist$ = "gals\" + galdir$(a) + "\" + galdir$(a) + ".lst"
 OPEN "i", 1, seclist$
 LINE INPUT #1, t$
 LINE INPUT #1, t$
 DO UNTIL EOF(1)
  LINE INPUT #1, t$
  secdir$ = RTRIM$(LEFT$(t$, 8))
  sector$ = "gals\" + galdir$(a) + "\" + secdir$ + "\" + secdir$ + ".dat"
  PRINT sector$
  SHELL "copy " + sector$ + " tmp.tmp"
  OPEN "i", 2, "tmp.tmp"
  OPEN "o", 3, sector$
  LINE INPUT #2, t$
  PRINT #3, t$
  FOR b = 1 TO 5
   LINE INPUT #2, t$
  NEXT b
  DO UNTIL EOF(2)
   LINE INPUT #2, t$
   PRINT #3, t$
  LOOP
  CLOSE 2
  CLOSE 3
  SHELL "del tmp.tmp"
 LOOP
 CLOSE 1
NEXT a

