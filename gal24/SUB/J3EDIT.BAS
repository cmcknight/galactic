REM personal jump route table editor v1.1
REM for use with galactic
REM this program edits data\j3.dat
REM
REM jim vassilakos (jimv@empirenet.com)

DIM j$(17)
x = 1: y = 1

OPEN "i", 1, "data\j3.dat"
FOR a = 1 TO 17
   LINE INPUT #1, j$(a)
NEXT a
CLOSE 1

50 REM show table
CLS
COLOR 14
FOR a = 1 TO 2
   PRINT j$(a)
NEXT a
COLOR 11
FOR a = 3 TO 17
   PRINT j$(a)
NEXT a

REM show marker
COLOR 10
LOCATE y + 2, x * 9 + 2
PRINT ">"
LOCATE y + 2, x * 9 + 4
PRINT "<"

REM show instructions
LOCATE 5, 50: COLOR 12
PRINT "? = Help"
LOCATE 6, 50
PRINT "X = Exit w/o Saving"
LOCATE 7, 50
PRINT "Q = Save & Quit"

100 REM get input
GOSUB 900
IF k2 = 0 AND (k1 >= 97 AND k1 <= 122) THEN k1 = k1 - 32
IF k2 = 0 AND k1 = 81 GOTO 950: REM q
IF k2 = 0 AND k1 = 88 GOTO 1000: REM x
IF k2 = 1 AND k1 = 72 GOTO 110: REM up
IF k2 = 0 AND k1 = 75 GOTO 110: REM k
IF k2 = 1 AND k1 = 80 GOTO 120: REM down
IF k2 = 0 AND k1 = 74 GOTO 120: REM j
IF k2 = 1 AND k1 = 75 GOTO 130: REM left
IF k2 = 0 AND k1 = 72 GOTO 130: REM h
IF k2 = 1 AND k1 = 77 GOTO 140: REM right
IF k2 = 0 AND k1 = 76 GOTO 140: REM l
IF k2 = 0 AND k1 = 63 GOTO 150: REM ?
IF k2 = 0 AND k1 = 45 GOTO 200: REM -
IF k2 = 0 AND k1 >= 48 AND k1 <= 54 GOTO 200: REM 0-6
GOTO 100

110 REM up
y = y - 1
IF y = 0 THEN y = 15
GOTO 50

120 REM down
y = y + 1
IF y = 16 THEN y = 1
GOTO 50

130 REM left
x = x - 1
IF x = 0 THEN x = 4
GOTO 50

140 REM right
x = x + 1
IF x = 5 THEN x = 1
GOTO 50

150 REM help
CLS : COLOR 11
PRINT
PRINT "The numbers in the chart represent the minimum"
PRINT "values the computer needs to roll on a six-sided"
PRINT "dice to get a jump route between two given worlds"
PRINT "with the indicated starports at a given distance"
PRINT "from one another."
PRINT
PRINT "Modify the values by moving the cursor around"
PRINT "with the arrow keys and then hitting the"
PRINT "appropriate number key. You can also use a dash"
PRINT "to indicate that there is no chance of a jump"
PRINT "route being present."
PRINT
PRINT "For addition help, contact jimv@empirenet.com"
PRINT
GOSUB 900
GOTO 50

200 REM input
IF k1 = 48 THEN k1 = 45
i = y + 2
j = x * 9 + 3
t$ = j$(i)
j$(i) = LEFT$(t$, j - 1) + CHR$(k1) + RIGHT$(t$, 39 - j)
GOTO 50

900 REM get character from keyboard
k1 = 0: k2 = 0
910 k$ = INKEY$
IF k$ = "" THEN GOTO 910
k1 = ASC(k$)
IF k1 <> 0 THEN RETURN
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
RETURN

950 REM save
OPEN "o", 1, "data\j3.dat"
FOR a = 1 TO 17
   PRINT #1, j$(a)
NEXT a
CLOSE 1

1000 REM end
COLOR 7
CLS
PRINT
PRINT "All done..."
PRINT
END

