
DIM lin$(3)

REM Configuration Program
REM For Use with Galactic v2.4
REM Public Domain 1998 Jim Vassilakos

REM read configuration
OPEN "i", 1, "gal.cfg"
FOR a = 1 TO 3
   LINE INPUT #1, lin$(a)
NEXT a
CLOSE 1

REM command$
cmd = VAL(COMMAND$)
IF cmd < 1 OR cmd > 3 GOTO 10010

20 REM
IF cmd = 1 GOTO 100: REM 1 (editor)
IF cmd = 2 GOTO 200: REM 2 (reader)
IF cmd = 3 GOTO 300: REM 3 (colors)
GOTO 20

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

100 REM editor
CLS
COLOR 11
PRINT "When viewing subsector maps, you have the option to edit"
PRINT "the subsector data file ('<' key), or create world"
PRINT "description files ('enter' key), or edit those world"
PRINT "descriptions if they already exist ('>' key). The only"
PRINT "question, of course, is which editor do you want to use?"
PRINT "An easy one called 'edit' is supplied with the most"
PRINT "recent versions of DOS, however, it's a glutton for"
PRINT "memory and may end up causing problems. One more"
PRINT "preferred by UNIX aficionados is called 'vi' and is"
PRINT "supplied with Galactic if you would prefer using that"
PRINT "instead. Yet another, called 'ted' is also suppied, and"
PRINT "ted has the advantage of being highly light-weight in"
PRINT "terms of memory usage. Alternately, you might have"
PRINT "another favorite editor. Enter the name of the editor"
PRINT "you want to use at the prompt or just hit <enter> to"
PRINT "choose 'ted'."
PRINT
COLOR 13
INPUT "Editor --->", t$
t$ = LTRIM$(RTRIM$(t$))
IF t$ = "" THEN t$ = "ted"
lin$(1) = "editor:" + t$
GOTO 10000

200 REM reader
CLS
COLOR 11
PRINT "When viewing subsector maps, you have the option to read"
PRINT "various world descriptions which you have previously"
PRINT "created ('enter' key used at a red hex). When you do"
PRINT "this, what you are actually doing is accessing a text"
PRINT "file with some variety of text reading software. One"
PRINT "common text reader used in the UNIX environment is called"
PRINT "'less', and a DOS version of 'less' is supplied as part"
PRINT "of this software package. One problem with 'less',"
PRINT "however, is that it ignores tilde (~) characters. Hence,"
PRINT "WWW addresses tend to get screwed up. There is also a"
PRINT "text reader called 'browse' which is also available."
PRINT "However, you may have another text reader which you'd"
PRINT "prefer to use. If so, enter the name of that reader at"
PRINT "the prompt or just hit <enter> if you want to use 'less'."
PRINT
COLOR 13
INPUT "Reader --->", t$
t$ = LTRIM$(RTRIM$(t$))
IF t$ = "" THEN t$ = "less"
lin$(2) = "reader:" + t$
GOTO 10000

300 REM colors
CLS
COLOR 11
PRINT "Galactic typically displays its maps with a black"
PRINT "background, however, since you may wish to take"
PRINT "screen snapshots from the printer, you might prefer"
PRINT "a white background instead. Please choose from"
PRINT "among the following options:"
PRINT
PRINT "(1) Colors on Black      (3) White on Black"
PRINT "(2) Colors on White      (4) Black on White"
PRINT
320 REM get input
GOSUB 60
IF k2 = 0 AND k1 = 27 GOTO 10010: REM esc
IF k2 = 0 AND (k1 = 81 OR k1 = 113) GOTO 10010: REM Q/q
IF k2 = 0 AND k1 >= 49 AND k1 <= 52 GOTO 330: REM 1-4
GOTO 320
330 REM the choice is made
lin$(3) = "colors:" + CHR$(k1)
GOTO 10000

10000 REM
OPEN "o", 1, "gal.cfg"
FOR a = 1 TO 3
 PRINT #1, lin$(a)
NEXT a
CLOSE
10010 COLOR 7: CLS
PRINT "Been fun..."
END

