#include "hasher.h"

void printHash( uint8_t* myHash )
{
    for(uint8_t w=0; w<8; w++){
        for(uint8_t b=0; b<8; b++){
            printf( "%02X", myHash[w*8+b] );
        }
    }
    printf("\n");
}

uint8_t* mySha512(char* inputString)
{
    // grab the input string
    char* myString = inputString;

    // ensure the input is not empty
    if(myString == NULL){
        myString = "";
    }

    // declare this because we use it a bunch
    int inputLen = strlen(myString);

    // convert each char into binary
    // add the resultant ints to intList
    int* intList = malloc(inputLen*8);
    for(int i=0; i<inputLen; i++)
    {
        // grab the ith char of the string
        char tempChar = myString[i];

        // create a pointer for the char
        char* charPtr = malloc(2);
        charPtr[0] = tempChar;
        charPtr[1] = '\0';

        // convert the char into a binary string
        char* tempString = stringToBinary(charPtr);

        // interpret the binary string as an integer value
        int tempInt = strtol(tempString, NULL, 2);
    
        // add that int to intList
        intList[i] = tempInt; 
    }
    // flush the stdout buffer because c has print hiccups
    fflush(stdout);

    // store the int list as a uint8_t list
    uint8_t* eightBitList = malloc(inputLen*8);
    for(int i=0; i<inputLen; i++)
    {
        eightBitList[i] = intList[i];
    }

    //declare some arguments for sha512()
    const uint64_t mySize = inputLen;
    uint8_t* myReturn = malloc( 64 );
    
    // execute the sha512()
    sha512( eightBitList, mySize, myReturn );
   
    // print the results
    //printHash( myReturn );

    return myReturn;
}

uint8_t* hashFile( char* filepath )
{
    // declare a file pointer
    FILE* f;

    // open the file
    f = fopen( filepath, "rb" );
    
    // read the contents of the file into a string buffer
    fseek( f, 0, SEEK_END );
    long fsize = ftell( f );
    fseek( f, 0, SEEK_SET );
    char* myString = malloc( fsize + 1 );
    fread( myString, fsize, 1, f );

    // close the file
    fclose(f);
    
    // hash the string buffer and return
    return( mySha512( myString ) );
}

unsigned long long hashToNum( uint8_t* myHash )
{
    return( myHash[0] );
}
