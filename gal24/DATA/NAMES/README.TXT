Charles Collin (charles@hebb.psych.mcgill.ca), whose homepage can
be found at http://www.psych.mcgill.ca/labs/cvl/home.html, created
all of the names files in this directory except for solomani.dat
which was distributed as names.dat in Galactic versions 2.0 & 2.1.
Each of these names files contains possible world names for alien
sectors. The names files are:

     aslan.dat
     darrian.dat
     droyne.dat
     kkree.dat
     solomani.dat
     vargr-g.dat
     vargr-v.dat
     vilani.dat
     zhodani.dat

As Galactic uses names from these files for the purpose of
generating named worlds, it deletes the names it uses from these
files so that they are not accidentally used twice (we assume that
you don't want two worlds bearing the same name). Since these files
are constantly diminishing in size as you generate worlds, I
figured it might be helpful to you to have access to the original
versions. These can be found in the "old" subdirectory.

Charles also created a batch file called mixname1.bat which
scrambles the names files so that two users generating a random
sector won't end up with worlds bearing the exact same names (i.e.
names taken from the top of whatever names file is in use). In
order to do its magic, mixname1.bat calls a program Charles wrote
named addnums.exe (source=addnums.c) which adds random numbers to
every line of whatever names file is being scrambled. Then the
batch file calls a shareware sorting program called msort.exe
(written by Martin Katz of Irvine, Caifornia and located in the
msort directory) in order to sort the file. Because of the random
numbers added by addnums.exe, sorting the file has the effect of
actually scrambling it, at least once losenums.exe (source=
losenums.c) deftly removes these random numbers.

I have modified mixname1.bat, naming the new version mixname2.bat.
This version operates assuming the user's current directory is two
levels up (one level above the data directory), in the main
Galactic directory, and is intended for use by Galactic's world
generation utilities. Attempting to run mixname2.dat from the
data\names directory will only cause problems, so consider
yourself warned.

One additional note: If you don't like msort.exe for some reason,
you can find various alternatives on the net. We were originally
using one called rpsort.com which was developed by Robert Pirko of
Bronx, New York. There are still others, so you may want to look
around and see what best suits your requirements.

 - Jim Vassilakos (jimv@empirenet.com)

