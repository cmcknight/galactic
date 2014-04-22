
DIM tmod(6, 20)
DIM spres(3, 12)
DIM nstat(8)
DIM sstat$(8)
RANDOMIZE (TIMER / 2)

FOR i = 0 TO 20
FOR j = 1 TO 6
READ tmod(j, i)
NEXT j
NEXT i
FOR i = 1 TO 3
FOR j = 2 TO 12
READ spres(i, j)
NEXT j
NEXT i

CLS
FOR z = 1 TO 50

REM worldsize
numdice = 2: GOSUB 100
nstat(2) = result - 2

REM atmosphere
numdice = 2: GOSUB 100
nstat(3) = result - 7 + nstat(2)
IF nstat(2) = 0 THEN nstat(3) = 0
IF nstat(3) < 0 THEN nstat(3) = 0
IF nstat(3) > 15 THEN nstat(3) = 15

REM hydrographics
numdice = 2: GOSUB 100
nstat(4) = result - 7 + nstat(2)
IF nstat(3) <= 1 THEN nstat(4) = nstat(4) - 4
IF nstat(3) >= 10 AND nstat(3) <= 12 THEN nstat(4) = nstat(4) - 4
IF nstat(3) = 14 THEN nstat(4) = nstat(4) - 2
IF nstat(2) <= 1 THEN nstat(4) = 0
IF nstat(4) > 10 THEN nstat(4) = 10
IF nstat(4) < 0 THEN nstat(4) = 0

REM population
numdice = 2: GOSUB 100
nstat(5) = result - 2
IF nstat(2) <= 2 THEN nstat(5) = nstat(5) - 1
IF nstat(3) <= 3 THEN nstat(5) = nstat(5) - 3
IF nstat(3) = 10 THEN nstat(5) = nstat(5) - 2
IF nstat(3) = 11 THEN nstat(5) = nstat(5) - 3
IF nstat(3) = 12 THEN nstat(5) = nstat(5) - 4
IF nstat(3) > 12 THEN nstat(5) = nstat(5) - 2
IF nstat(3) = 6 THEN nstat(5) = nstat(5) + 3
IF nstat(3) = 5 OR nstat(3) = 8 THEN nstat(5) = nstat(5) + 1
IF nstat(4) = 0 AND nstat(3) > 3 THEN nstat(5) = nstat(5) - 2
IF nstat(5) > 10 THEN nstat(5) = 10
IF nstat(5) < 0 THEN nstat(5) = 0

REM starport
numdice = 2: GOSUB 100
nstat(1) = spres(2, result)
IF nstat(5) = 0 THEN nstat(1) = 6
IF nstat(5) = 1 THEN nstat(1) = nstat(1) + 2
IF nstat(5) = 2 THEN nstat(1) = nstat(1) + 1
IF nstat(5) >= 6 THEN nstat(1) = nstat(1) - 1
IF nstat(5) = 10 THEN nstat(1) = nstat(1) - 1
IF nstat(1) > 6 THEN nstat(1) = 6
IF nstat(1) < 1 THEN nstat(1) = 1

REM government
numdice = 2: GOSUB 100
nstat(6) = result - 7 + nstat(5)
IF nstat(5) = 0 THEN nstat(6) = 0
IF nstat(6) < 0 THEN nstat(6) = 0
IF nstat(6) > 15 THEN nstat(6) = 15

REM lawlevel
numdice = 2: GOSUB 100
nstat(7) = result - 7 + nstat(6)
IF nstat(6) = 0 THEN nstat(7) = 0
IF nstat(7) < 0 THEN nstat(7) = 0

REM techlevel
numdice = 1: GOSUB 100
nstat(8) = result
FOR i = 1 TO 6
nstat(8) = nstat(8) + tmod(i, nstat(i))
NEXT i
IF nstat(5) = 0 THEN nstat(8) = 0
IF nstat(5) <> 0 THEN
   IF nstat(8) < 4 AND nstat(5) >= 6 THEN
      IF nstat(4) = 0 OR nstat(4) = 10 THEN
          nstat(8) = 4 + INT(RND * 2)
      END IF
   END IF
   IF nstat(8) < 5 THEN
      IF (nstat(3) = 4 OR nstat(3) = 7 OR nstat(3) = 9) THEN
         nstat(8) = 5 + INT(RND * 2)
      END IF
   END IF
   IF nstat(8) < 7 THEN
      IF (nstat(3) <= 3 OR (nstat(3) >= 10 AND nstat(3) <= 12)) THEN
         nstat(8) = 7 + INT(RND * 2)
      ELSEIF ((nstat(3) = 13 OR nstat(3) = 15) AND nstat(4) = 10) THEN
         nstat(8) = 7 + INT(RND * 2)
      END IF
   END IF
END IF

IF nstat(8) < 0 THEN nstat(8) = 0

REM convert nstat to sstat$
sstat$(1) = CHR$(nstat(1) + 64)
IF sstat$(1) = "F" THEN sstat$(1) = "X"
FOR i = 2 TO 8
IF nstat(i) < 10 THEN sstat$(i) = RIGHT$(STR$(nstat(i)), 1)
IF nstat(i) >= 18 THEN nstat(i) = nstat(i) + 1
IF nstat(i) >= 10 THEN sstat$(i) = CHR$(nstat(i) + 55)
NEXT i

REM print system
FOR i = 1 TO 8
PRINT sstat$(i);
IF i = 7 THEN PRINT "-";
NEXT i
IF z MOD 5 = 0 THEN PRINT
IF z MOD 5 <> 0 THEN PRINT "    ";

NEXT z
END

100 REM roll d6ers
REM in -> numdice
REM out -> result
result = 0
FOR n = 1 TO numdice
result = result + INT(6 * RND) + 1
NEXT n
RETURN

DATA 0,2,1,0,0,1
DATA 6,2,1,0,1,0
DATA 4,1,1,0,1,0
DATA 2,1,1,0,1,0
DATA 0,1,0,0,1,0
DATA 0,0,0,0,1,1
DATA -4,0,0,0,0,0
DATA 0,0,0,0,0,0
DATA 0,0,0,0,0,0
DATA 0,0,0,1,2,0
DATA 0,0,1,2,4,0
DATA 0,0,1,0,0,0
DATA 0,0,1,0,0,0
DATA 0,0,1,0,0,-2
DATA 0,0,1,0,0,0
DATA 0,0,1,0,0,0
DATA 0,0,0,0,0,0
DATA 0,0,0,0,0,0
DATA 0,0,0,0,0,0
DATA 0,0,0,0,0,0
DATA 0,0,0,0,0,0
DATA 1,1,2,2,3,3,3,4,5,5,6
DATA 1,1,1,2,2,3,3,4,5,5,6
DATA 1,1,1,2,2,3,3,4,5,5,5

