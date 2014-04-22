
Convert-23
----------

This program converts Galactic v2.3 galaxies to Galactic v2.4
format. It is meant to be run from the directory containing your
copy of Galactic v2.3.

What the program does:

(1) It creates a "gals" directory, and then copies all your
galaxies into it.

(2) After that it creates a number of files called "where.dat" in
the gals directory and in each of the galaxy subdirectories.
Galactic v2.4 needs these new files in order to know where it is
starting out when you enter any given galaxy. The gals\where.dat
file contains the directory name of the galaxy that was last
viewed. The galaxy-level where.dat files each contain the
coordinates (X,Y) of the sector that was last viewed.

(3) Then it revises each of the sector lists (gals\<galaxy>\
<galaxy>.lst), adding three new bits of data to each sector which
is listed (X, Y, Color). The X,Y values determine the location of
the sector within its galaxy (this you will have to amend
manually, perhaps using Gal24's gals\classic\classic.lst as a
template, or via the 'F6-move sector' command from the galaxy
menu, as all your sectors will initially be placed in a straight
line by this program). The Color value determines what color is
used when the sector is displayed on the galaxy map. See "Sector
Lists" below for a more in-depth explanation.

(4) Then it revises the "@dir=" line in all the menu files it can
find underneath the gals directory, so that these menus will know
where they are located in the overall directory structure.

(5) Then it revises each of the sector files (gals\<galaxy>\
<sector>\<sector>.dat), removing the North/South/East/West lines.
Sector location is now controlled by the sector lists (see Step
#3).

------------
SECTOR LISTS
------------

Step 3 hints at what is perhaps the most significant data format
change, the three new values in the sector lists. A typical (v2.4)
sector list might read as follows:

Directory of Sectors
-------------------------------------------------------------
mid          Middle Sector                        0    0    I
north        North Sector                         0    -1   I
west         West Sector                          -1   0    I
south        South Sector                         0    1    I
east         East Sector                          1    0    I
ne           Northeast Sector                     1    -1   I
nw           Northwest Sector                     -1   -1   K
sw           Southwest Sector                     -1   1    I
se           Southeast Sector                     1    1    K

The two numbers (X,Y) determine the location of the sector. The
idea here is that X gets bigger as you go to the right (east). Y
gets bigger as you go down (south). Negative numbers are
perfectly acceptable.

The letter at the end (Color) determines the color used to
display the sector:

    A  Black    E  Red       I  Dark Grey     M  Light Red
    B  Blue     F  Magenta   J  Light Blue    N  Light Magenta
    C  Green    G  Brown     K  Light Green   O  Light Yellow
    D  Cyan     H  White     L  Light Cyan    P  Bright White

I've been using "L" (light cyan) for sector that are developed
(which have world write-ups, etc). "K" (light green) has been
used for sectors that have been generated but not developed (the
sector data exists, but there are no world write-ups). "I" (dark
grey) has been used for sectors that do not exist except in name
(no data has been generated for them).

You can use any of the colors to represent your sectors, and they
can mean whatever you want them to mean, however, "I" (dark grey)
is a reserved color in the sense that Galactic will assume that
all dark grey sectors do not exist except in name.

If you have any questions, or if you need help doing the data
format conversion, just let me know... -Jim

jimv@empirenet.com
http://members.aol.com/jimvassila

