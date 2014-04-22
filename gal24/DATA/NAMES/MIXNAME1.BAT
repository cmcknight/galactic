@echo off
rem   This batch file uses three small programs and some DOS commands to 
rem   mix up ASCII files containing lists of words (one word per line and
rem   max line length is 20 characters).  For help with this batch 
rem   file or any of the programs it calls, contact Charles Collin: 
rem   charles@hebb.psych.mcgill.ca
rem 
rem   
rem   Format is mixname1 infile outfile
rem
rem   You can manually execute this version directly from the
rem   data\names directory, that is the directory in which
rem   this batch file is located.
rem
rem   Here's what's going on:
rem
rem   First, add random numbers to words read from infile and write the output 
rem   to tempnam1.txt
ADDNUMS %1
rem
rem   Second, sort tempnam1.txt according to these leading numbers and 
rem   overwrite old unsorted tempnam1.txt.
MSORT\MSORT < tempnam1.txt > tempnam2.txt
ERASE tempnam1.txt
RENAME tempnam2.txt tempnam1.txt
rem
rem   Third, read tempnam1.txt into tempnam2.txt without leading nums.
LOSENUMS
rem 
rem   Copy tempnam2.txt to the outfile.
COPY tempnam2.txt %2
rem
rem   Get rid of the temporary files.
DEL tempnam1.txt
DEL tempnam2.txt
@echo on
