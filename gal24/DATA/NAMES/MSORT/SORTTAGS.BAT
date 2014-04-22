@echo off
:: Sort Tag Line files and eliminate most duplicates.
:: Copyright 1994 by Martin Katz, Ph.D. All rights reserved

:: This file is distributed as part of the MSORT package (version 1.0)
:: and it serves as an example of how to use the program.
echo off

if "%1" == "" goto NeedFile
if "%1" == "%2" goto NeedFile
if not exist %1 goto NeedFile

echo Sorting taglines from %1
msort -# -c -t -u -b %1 -otags.srt
if not errorlevel 1 goto SortOK
echo.
echo Error in sorting
if exist tags.srt del tags.srt
echo.
echo Note: You may have to delete the temporary files.
echo.
goto Done

:SortOK
if "%2" == "" goto UseDef
if exist %2 del %2
ren tags.srt %2
@echo Sorted taglines from %1 are in %2
goto Done

:UseDef
if exist tags.old del tags.old
ren %1 tags.old
ren tags.srt %1

@echo Taglines in %1 are sorted -- The original file is in tags.old.
goto Done

:NeedFile
echo.
echo    Please specify the tagline file to sort.
echo Usage:
echo    sorttags TagFile [SortedFile]
echo Where
echo    TagFile       is the file to be sorted
echo    SortedFile    (optional) is the file name for the sorted result.
echo                  If no SortedFile is specified, then TagFile is overwritten.

:Done
set s=
