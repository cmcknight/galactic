
TCSYNC is a Trade Code Synchronizer for Galactic 2.4c

Here are the files you should have in this gal24c.zip archive:

gal.bas      Put this into Galactic's root directory (it's a new version)
gal.exe      Put this into Galactic's root directory (it's a new version)

tcsync.bas   Put this into Galactic's "sub" directory
tcsync.exe   Put this into Galactic's "sub" directory

tcsync.txt   Put this into Galactic's "help" directory
sec-cmd.txt  Put this into Galactic's "help" directory (it's a new version)
sub-cmd.txt  Put this into Galactic's "help" directory (it's a new version)

hooks.dat    Put this into Galactic's "data" directory (it's a new verison)
             unless you have already manually modified it. If you have
             modified it by adding some "hooks" then compare this version
             of the file with your old version. You should notice that
             there are two new entries:

Under "Text Sector Map" you should see:

S        - 83 sub\tcsync sec <secdir>                           

And under "Subsector Map" you should see:

S        - 83 sub\tcsync sub <subfilepath>                      

If your version of data\hooks.dat is otherwise identical to this
updated verison, you can just copy this version over your old
version. If, however, there are some new "hooks" that you have
personally added, you may want to just add these two lines
manually so your don't lose the hooks that you've already added.

Once properly installed, you should be able to run the subprogram
by hitting "S" either at the green & yellow sector map or by
hitting "S" at the subsector map.

G'luck, and let me know if you have any questions...

Jim Vassilakos
jimvassila@aol.com

