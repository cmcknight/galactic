@echo off
rem   This batch file uses three small programs and some DOS commands to 
rem   mix up ASCII files containing lists of words (one word per line and
rem   max line length is 20 characters).  For help with this batch 
rem   file or any of the programs it calls, contact Charles Collin: 
rem   charles@hebb.psych.mcgill.ca
rem 
rem   
rem   Format is data\names\mixname2 infilepath outfilepath
rem
rem   *** WARNING ***
rem   This version of mixname is for use by Galactic and its subsidiary
rem   programs. Do not execute this batch file directly unless you're
rem   sure you know what you're doing. Execute mixname1 instead.
rem
rem   Here's what's going on:
rem
rem   First, add random numbers to words read from infile and write the output 
rem   to tempnam1.txt
DATA\NAMES\ADDNUMS %1
rem
rem   Second, sort tempnam1.txt according to these leading numbers and 
rem   overwrite old unsorted tempnam1.txt.
DATA\NAMES\MSORT\MSORT < tempnam1.txt > tempnam2.txt
ERASE tempnam1.txt
RENAME tempnam2.txt tempnam1.txt
rem
rem   Third, read tempnam1.txt into tempnam2.txt without leading nums.
DATA\NAMES\LOSENUMS
rem 
rem   Copy tempnam2.txt to the outfile.
COPY tempnam2.txt %2
rem
rem   Get rid of the temporary files.
DEL tempnam1.txt
DEL tempnam2.txt
@echo on
