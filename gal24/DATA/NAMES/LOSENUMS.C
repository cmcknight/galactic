/*Written by Charles Collin (charles@hebb.psych.mcgill.ca)                 */
/*Compiled using Microsoft C 6.0                                           */
/*This file takes tempnam1.txt, after it has been sorted by rpsort, and    */
/*writes it to tempnam2.txt while eliminating the leading numbers which are*/
/*no longer needed.  For more info, see the mixnames.bat file.             */

#include <stdlib.h>
#include <stdio.h>

main(int argc, char *argv[])
{
FILE *tempptrone;   /*Pointer to file with leading numbers for rpsort.*/
FILE *tempptrtwo;   /*Pointer to ordered file to be scrambled.*/

char ch;
int numofwords=0;   /*Number of words in input file*/
int x=0;            /*Just a forloop counter*/
char copyflag;      /*Flag indicating whether to copy ch to tempnam2.txt*/

/*Open files*/

if( (tempptrone=fopen("tempnam1.txt", "r")) == NULL)
    {printf("\nCan't open tempnam1.txt\n"); exit(0);}
if( (tempptrtwo=fopen("tempnam2.txt", "w")) == NULL)  
    {printf("\nCan't open tempnam2.txt\n"); exit(0);}

/*Make sure we start at the begining of input file*/
fseek(tempptrone, 0,0);

/*While we are not at the end of the file read each char from tempnam1.txt*/
while( (ch=(fgetc(tempptrone))) != EOF  )
    {
    if(ch==123) copyflag=0;  /*go into "do not copy" mode if you hit a '{'*/
    if(copyflag==1) fprintf(tempptrtwo, "%c", ch); /*write to tempnam2.txt*/ 
    if(ch==125) copyflag=1;  /*go into "yes copy it" mode if you hit a '}'*/
    }

/*Close files*/
fclose(tempptrone);
fclose(tempptrtwo);

exit(0);
}

