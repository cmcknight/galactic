/*Written by Charles Collin (charles@hebb.psych.mcgill.ca)                 */
/*Compiled using Microsoft C 6.0                                           */
/*This program takes an input file, reads it a line at a time, and outputs */
/*it to a temporary file 'tempnam1.txt' with a random number in braces     */
/*(i.e. '{' and '}') at the begining of each word.  When the file is sorted*/
/*according to these leading numbers it is effectively mixed up.           */
/*See the mixnames.bat file for more info.                                 */

#include <stdlib.h>
#include <stdio.h>

main(int argc, char *argv[])
{
FILE *inptr;        /*Pointer to ordered file to be scrambled.*/
FILE *tempptrone;   /*Pointer to temp file with leading numbers for rpsort.*/

char infile[15];    /*Name of ordered input file*/

char word[31];      /*Holds each word as it is read from infile.  If you   */
                    /*wish to use the program with longer lines of text,   */
                    /*you will have to increase this array size (eg. to 80)*/

char ch;            
int randomindex=0;  /*Numerical version of leading random numbers*/
char randomnum[15]; /*ASCII version of leading randomnumbers*/


char leadchar[3] = "{"; /*ASCII 123, this marks the start of leading nums.*/
char endchar[3] =   "}";/*ASCII 125, this marks the end of leading nums.*/
char wholestring[63] = "";  /*Holds the word being written, along with its*/
                            /*corresponding leading number and marker chars*/

int numofwords=0;   /*Number of words in input file*/
int x=0;            /*Just a forloop counter*/


srand( (unsigned)time( NULL ) );  /*Seed rand() with clock value*/

/*Check command line syntax*/
if(argc != 2) 
  {printf("\nSyntax problem, format is: C:>addnums infile.\n"); exit(0);}

/*Open files*/
if( (inptr=fopen(argv[1],"r")) == NULL)  
    {printf("\nCan't find input file\n"); exit(0);}
if( (tempptrone=fopen("tempnam1.txt", "w")) == NULL)
    {printf("\nCan't open tempnam1.txt\n"); exit(0);}

/*Count words in input file*/
while((ch = fgetc(inptr)) != EOF) if(ch==10) numofwords++;

/*Make sure we start at the begining of input file*/
fseek(inptr, 0,0);

/*Create new file containing each word from the input file, but preceeded */
/*by a random number.*/

/*For each word in input file...*/
for(x=1;x<=numofwords;x++)  
{
fgets(word, 80, inptr);     /*Get a word from the input file.*/
                                  
strcpy(wholestring, leadchar); /*Start the string to be copied with a '{' */

/*Generate a random number 0-64000 (approx.) and convert it to a string*/
itoa( (randomindex=(rand())), randomnum, 10); 
/*Add randomnum onto the end of the "lead character"*/
strcat(wholestring, randomnum);  
/*Add end character onto the end the lead character+random number string*/    
strcat(wholestring, endchar);
/*Add the word onto the end of the randomnumber with lead&end characters*/
strcat(wholestring, word);    

/*Print the whole concatenated string to a temp file.*/
fprintf(tempptrone, "%s", wholestring);  
}

/*Close files*/
fclose(tempptrone);
fclose(inptr);

exit(0);
}

