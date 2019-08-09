// adapted from stack overflow
// https://stackoverflow.com/questions/41384262/convert-string-to-binary-in-c

#include "toBinary.h"

//binary should be malloc( slen * CHAR_BIT + 1 )
void stringToBinary(char *s, char* binary)
{
  if (s == NULL) {
    // NULL might be 0 but you cannot be sure about it
    return;
  }
  // get length of string without NUL
  size_t slen = strlen(s);

  errno = 0;
  // allocate "slen" (number of characters in string without NUL)
  // times the number of bits in a "char" plus one byte for the NUL
  // at the end of the return value
  if(binary == NULL){
     fprintf(stderr,"malloc has failed in stringToBinary(%s): %s\n",s, strerror(errno));
     return;
  }
  // finally we can put our shortcut from above here
  if (slen == 0) {
    *binary = '\0';
    return;
  }
  char *ptr;
  // keep an eye on the beginning
  char *start = binary;
  int i;

  // loop over the input-characters
  for (ptr = s; *ptr != '\0'; ptr++) {
    /* perform bitwise AND for every bit of the character */
    // loop over the input-character bits
    for (i = CHAR_BIT - 1; i >= 0; i--, binary++) {
      *binary = (*ptr & 1 << i) ? '1' : '0';
    }
  }
  // finalize return value
  *binary = '\0';
  // reset pointer to beginning
  binary = start;
  return;
}

// changes the return into an int
int hexStringToInt( char* hexString )
{
    char* temp = hexString;
    return strtol(temp, NULL, 2);
}

