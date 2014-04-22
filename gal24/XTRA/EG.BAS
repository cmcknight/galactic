REM Electric Guildsman Menuing System 2.2
REM Public Domain 1998 Jim Vassilakos

DIM p(50)
DIM f$(50)
DIM back(50)
DIM l$(25)
DIM r$(25)
DIM row(25)
DIM colname$(16)

IF COMMAND$ = "" GOTO 8
IF INSTR(COMMAND$, ".MNU") > 0 THEN flag1 = 1
IF flag1 = 0 THEN flag2 = 1
IF INSTR(COMMAND$, " ") > 0 THEN flag2 = 1
IF flag1 = 0 AND flag2 = 1 GOTO 3
IF flag1 = 1 AND flag2 = 0 GOTO 4
IF flag1 = 1 AND flag2 = 1 GOTO 5
PRINT "Error in Command Line": END

3 REM flag2 only
reader$ = COMMAND$
GOTO 8

4 REM flag1 only
f$(1) = COMMAND$
GOTO 8

5 REM both flags
sp = INSTR(COMMAND$, " ")
f$(1) = LEFT$(COMMAND$, sp - 1)
reader$ = MID$(COMMAND$, sp + 1, LEN(COMMAND$) - sp)

8 OPEN "i", 1, "xtra\colors.dat"
FOR a = 0 TO 15
LINE INPUT #1, a$
colname$(a) = LCASE$(RIGHT$(a$, LEN(a$) - 4))
NEXT a
CLOSE

IF reader$ = "" THEN reader$ = "less "
p(1) = 1
IF f$(1) = "" THEN f$(1) = "main.mnu"
back(1) = 0
topp = 1: REM number of menus encountered

n = 1
10 REM read menu file
dir$ = ""
REM see if file exists
OPEN "r", 1, f$(n)
exist = LOF(1)
CLOSE 1
IF exist = 0 GOTO 950
SHELL "call xtra\egacolor 00 10"
SHELL "call xtra\egacolor 07 46"
OPEN "i", 1, f$(n)
CLS
q = 0: count = 0
DO UNTIL EOF(1)
   count = count + 1
   LINE INPUT #1, a$
   i = INSTR(a$, "@")
   IF i > 1 THEN i = INSTR(a$, " @")
   IF i > 1 THEN i = i + 1
   l = LEN(a$)
   IF i = 1 THEN
      IF LCASE$(MID$(a$, 2, 3)) = "dir" THEN
      dir$ = RIGHT$(a$, l - 5)
      IF RIGHT$(dir$, 1) <> "\" THEN dir$ = dir$ + "\"
      END IF
      FOR y = 0 TO 15
      IF LCASE$(RIGHT$(a$, l - 1)) = colname$(y) THEN COLOR y
      IF LCASE$(RIGHT$(a$, l - 1)) = colname$(y) + " blinking" THEN
         COLOR y + 16
      END IF
      NEXT y
      count = count - 1
   END IF
   IF i > 1 THEN
      q = q + 1
      l$(q) = LEFT$(a$, i - 1)
      r$(q) = dir$ + RIGHT$(a$, l - i)
      row(q) = count
      a$ = l$(q)
   END IF
   IF i <> 1 THEN PRINT a$
LOOP
CLOSE
hip = q: REM the number of possible choices

IF old = 0 THEN
   LOCATE 25, 75: COLOR 12
   PRINT "H=Help";
   old = 1
END IF

15 REM make arrow
LOCATE row(p(n)), 2
COLOR 12
PRINT CHR$(196); CHR$(26);

20 REM get input
GOSUB 60
IF k2 = 0 AND k1 = 27 GOTO 1000: REM esc
IF k2 = 0 AND (k1 = 81 OR k1 = 113) GOTO 1000: REM Q/q
IF k2 = 1 AND (k1 = 72 OR k1 = 80) GOTO 25: REM up/down
IF k2 = 0 AND (k1 = 74 OR k1 = 106) GOTO 25: REM J/j=down
IF k2 = 0 AND (k1 = 75 OR k1 = 107) GOTO 25: REM K/k=up
IF k2 = 1 AND (k1 = 75 OR k1 = 77) GOTO 25: REM left/right
IF k2 = 1 AND (k1 = 73 OR k1 = 81) GOTO 25: REM pgup/pgdn
IF k2 = 1 AND (k1 = 71 OR k1 = 79) GOTO 25: REM home/end
IF k2 = 0 AND k1 = 60 GOTO 30: REM <
IF k2 = 0 AND k1 = 62 GOTO 35: REM >
IF k2 = 0 AND k1 = 13 GOTO 45: REM enter
IF k2 = 0 AND k1 = 32 GOTO 45: REM space
IF k2 = 0 AND (k1 = 72 OR k1 = 104 OR k1 = 63) GOTO 70
IF k2 = 0 AND (k1 = 67 OR k1 = 99) GOTO 80: REM C/c
GOTO 20

25 REM up & down arrow movement
LOCATE row(p(n)), 2
PRINT "  "
IF k2 = 1 THEN
IF k1 = 72 THEN p(n) = p(n) - 1: REM up
IF k1 = 80 THEN p(n) = p(n) + 1: REM down
IF k1 = 75 THEN p(n) = p(n) - 1: REM left
IF k1 = 77 THEN p(n) = p(n) + 1: REM right
IF k1 = 73 OR k1 = 71 THEN p(n) = 1: REM pgup/home
IF k1 = 81 OR k1 = 79 THEN p(n) = hip: REM pgdn/end
END IF
IF k2 = 0 THEN
IF k1 = 74 OR k1 = 106 THEN p(n) = p(n) + 1: REM J/j
IF k1 = 75 OR k1 = 107 THEN p(n) = p(n) - 1: REM K/k
END IF
IF p(n) > hip THEN p(n) = 1
IF p(n) < 1 THEN p(n) = hip
GOTO 15

30 REM < check out this file directly
COLOR 7: CLS : PRINT "."
e$ = "call " + reader$ + " " + f$(n)
SHELL "call xtra\egacolor 00 10"
SHELL "call xtra\egacolor 07 46"
SHELL e$
GOTO 10

35 REM > check out that file directly
ext$ = RIGHT$(r$(p(n)), 3)
IF ext$ = "txt" GOTO 45
IF ext$ <> "mnu" GOTO 10
COLOR 7: CLS : PRINT "."
e$ = "call " + reader$ + " " + r$(p(n))
SHELL "call xtra\egacolor 00 10"
SHELL "call xtra\egacolor 07 46"
SHELL e$
GOTO 10

45 REM select
ext$ = RIGHT$(r$(p(n)), 3)
IF ext$ = "exe" OR ext$ = "com" OR ext$ = "bat" THEN
   e$ = "call " + r$(p(n))
   SHELL e$
END IF
IF ext$ = "txt" OR ext$ = "dat" OR ext$ = "bas" THEN
   COLOR 7: CLS : PRINT "."
   e$ = "call " + reader$ + " " + r$(p(n))
   SHELL "call xtra\egacolor 00 10"
   SHELL "call xtra\egacolor 07 46"
   SHELL e$
END IF
IF ext$ = "asc" THEN
   COLOR 7: CLS : PRINT ".": CLS
   SHELL "call xtra\egacolor 00 10"
   SHELL "call xtra\egacolor 07 46"
   tmp$ = "type"
   IF reader$ = "EDIT" THEN tmp$ = "edit"
   SHELL tmp$ + " " + r$(p(n))
   IF tmp$ = "type" THEN GOSUB 60
END IF
IF ext$ <> "mnu" THEN GOTO 10
REM determine if we've been there before
there = 0
FOR z = 1 TO topp
   IF r$(p(n)) = f$(z) THEN there = z
NEXT z
REM yes we have
IF there <> 0 THEN n = there
REM no we haven't, so let's make a new place
IF there = 0 THEN
   topp = topp + 1
   back(topp) = n
   f$(topp) = r$(p(n))
   p(topp) = 1
   n = topp
END IF
GOTO 10

60 REM read keyboard
k1 = 0: k2 = 0
62 k$ = INKEY$
IF k$ = "" THEN GOTO 62
SOUND 10000, .1
k1 = ASC(k$)
IF k1 <> 13 THEN GOTO 63
FOR note = 1 TO 10
SOUND note * 200, .1
NEXT note
63 IF k1 <> 0 THEN GOTO 64
k1 = ASC(RIGHT$(k$, 1))
k2 = 1
64 RETURN

70 REM help
CLS : COLOR 11: PRINT
PRINT "Publish your own electronic books with the..."
PRINT : COLOR 14
PRINT "   Electric Guildsman Menuing System v2.11"
PRINT "   Public Domain 1997 Jim Vassilakos"
PRINT : COLOR 12
PRINT "Command Line: eg [<file.mnu>] [<textbrowser>]"
PRINT "   default file.mnu = main.mnu"
PRINT "   default textbrowser = less"
PRINT : COLOR 13
PRINT "Commands:  < : Browse This Menu      > : Browse That Menu"
PRINT "           C : Change Browser        Q : Quit"
PRINT "           Arrows : Move Pointer     Enter : Select Item"
PRINT
PRINT "Recognized File Extensions:"
PRINT "   txt/dat/bas: Vanilla Text     asc: Ascii (Non-Vanilla)"
PRINT "   bat/com/exe: Executable       mnu: Menu"
PRINT : COLOR 11
PRINT "For help & stuff, send email to:"
PRINT "   jimv@empirenet.com               jimv@cs.ucr.edu"
PRINT "   jimv@silver.lcs.mit.edu          jimv@wizards.com"
GOSUB 60: GOTO 10

80 REM change browser
CLS : PRINT : COLOR 11
PRINT "This program is just a menuing system. The actual text"
PRINT "reading/editing is done by another program, called the"
PRINT "text browser. You can use any text browsers you want."
PRINT "Some examples are:"
PRINT : COLOR 10
PRINT "  less      Read-only, easy to use, ignores tilde (~)"
PRINT " browse     Read-only, also easy to use"
PRINT "  ted       Editor, easy to use and light-weight"
PRINT "  edit      Editor, easy to use but heavy on memory"
PRINT "   vi       Editor, difficult for beginners (see vi.hlp)"
PRINT : COLOR 11
PRINT "You can even use a wordprocessor such as 'wp' if you"
PRINT "like. Just make sure you save your work as text, not"
PRINT "in wp-format."
PRINT : COLOR 13
PRINT "Your current text brower is "; reader$
PRINT : COLOR 12
INPUT "Enter name of new text browser: ", nr$
IF nr$ <> "" THEN reader$ = nr$
GOTO 10

950 REM menu file doesn't exist
SHELL "erase " + f$(n)
CLS : COLOR 14: LOCATE 8
PRINT "OOOPSY...": PRINT
COLOR 11: PRINT f$(n);
COLOR 14: PRINT " doesn't exist": PRINT
PRINT "You may want to check this out  ";
COLOR 13: PRINT ":-)"
GOSUB 60

1000 REM quit
IF back(n) = 0 GOTO 1010
n = back(n)
GOTO 10
1010 COLOR 7
CLS
PRINT : PRINT
PRINT "Have a nice day..."
PRINT
END

