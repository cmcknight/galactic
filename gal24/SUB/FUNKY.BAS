
REM Funky File Viewer
REM Copyright 1995 Jim Vassilakos
REM San Bernardino, California
REM jimv@empirenet.com / jimvassila@aol.com

IF COMMAND$ = "" THEN
   PRINT
   PRINT "This program reads funkily-formated text."
   PRINT "See title.dat for an example."
   PRINT
   PRINT "   Format:   Funky <textfile>"
   PRINT
   END
END IF

OPEN "i", 1, COMMAND$
10 LINE INPUT #1, t$
l = LEN(t$)
IF l = 0 GOTO 15
IF LEFT$(t$, 1) = "#" THEN GOTO 90
IF l < 7 GOTO 12
IF LEFT$(t$, 7) = "*Color=" THEN GOTO 20
IF LEFT$(t$, 7) = "*Funky=" THEN GOTO 30
12 IF funky = 1 THEN GOTO 40
IF funky = 0 THEN GOTO 50

15 PRINT
GOTO 90

20 COLOR VAL(RIGHT$(t$, l - 7))
GOTO 90

30 IF RIGHT$(t$, 2) = "On" THEN funky = 1
IF RIGHT$(t$, 3) = "Off" THEN funky = 0
GOTO 90

40 REM funky
FOR t2 = 1 TO LEN(t$)
t2$ = MID$(t$, t2, 1)
t = VAL(t2$)
IF t = 0 THEN tt = 32
IF t = 1 THEN tt = 201
IF t = 2 THEN tt = 205
IF t = 3 THEN tt = 187
IF t = 4 THEN tt = 186
IF t = 5 THEN tt = 206
IF t = 7 THEN tt = 200
IF t = 9 THEN tt = 188
IF t2$ = "U" THEN tt = 202
IF t2$ = "D" THEN tt = 203
IF t2$ = "L" THEN tt = 185
IF t2$ = "R" THEN tt = 204
IF t2$ = "o" THEN tt = 248
PRINT CHR$(tt);
NEXT t2
PRINT
GOTO 90

50 REM non-funky
PRINT t$

90 IF EOF(1) <> -1 GOTO 10
CLOSE

