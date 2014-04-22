' Find World 1.0
' Public Domain 1998 Jim Vassilakos
' jimv@empirenet.com

DIM secdir$(100)

c$ = COMMAND$
c$ = "gals\classic"
c$ = RTRIM$(LTRIM$(LCASE$(c$)))

10 CLS : COLOR 11: LOCATE 5, 1
PRINT SPACE$(79)
LOCATE 5, 1
INPUT "Name of World that you're looking for: ", search$
search$ = RTRIM$(LTRIM$(search$))
IF search$ = "" GOTO 10000
IF INSTR(search$, " ") <> 0 GOTO 10

OPEN "i", 1, "gal.cfg"
LINE INPUT #1, t$: editor$ = RIGHT$(t$, LEN(t$) - 7)
LINE INPUT #1, t$: reader$ = RIGHT$(t$, LEN(t$) - 7)
CLOSE 1

i = INSTR(c$, "\")
gal0$ = RIGHT$(c$, LEN(c$) - i)
seclist$ = c$ + "\" + gal0$ + ".lst"

OPEN "i", 1, seclist$
LINE INPUT #1, t$
LINE INPUT #1, t$
i = 0
DO UNTIL EOF(1)
   LINE INPUT #1, t$
   t$ = RTRIM$(LTRIM$(t$))
   IF t$ = "" GOTO 100
   IF LEFT$(t$, 1) = "#" GOTO 100
   IF MID$(t$, 61, 1) = "I" GOTO 100
   i = i + 1
   secdir$(i) = RTRIM$(LEFT$(t$, 8))
100 LOOP
CLOSE 1
numsecs = i

IF numsecs = 0 GOTO 10000

OPEN "o", 1, "tmp.tmp"
PRINT #1, "Search for '"; search$; "':"
PRINT #1, ""
CLOSE 1

FOR a = 1 TO numsecs
f$ = "gals/" + gal0$ + "/" + secdir$(a)
PRINT "Searching "; f$
s$ = "xtra\grep -i " + search$ + " " + f$ + "/map/*.dat >> tmp.tmp"
SHELL s$
NEXT a

SHELL "xtra\egacolor 00 10"
SHELL "xtra\egacolor 07 46"
SHELL reader$ + " tmp.tmp"
SHELL "del tmp.tmp"

COLOR 7: PRINT ".": CLS
10000 END

