#include <stdint.h>
#include <stdio.h>
#include <string.h>

#include "sign.h"

void ffisignMsg(    const uint8_t* in, 
                    const long in_len, 
                    uint8_t* out, 
                    const long out_len ) 
{

    int rc;

    //char input[in_len];
    //strcpy(input, in);
    char input[] = "sign -h";

    char* tpmArgv[50];
    int tpmArgc = 0;

    char* token;
    char* saveptr;
    token = strtok_r(input, " ", &saveptr);
    tpmArgv[tpmArgc] = token;
    tpmArgc = tpmArgc + 1;
    while (token != NULL)
    {
        token = strtok_r(NULL, " ", &saveptr);
        if (token != NULL)
        {
            tpmArgv[tpmArgc] = token;
            tpmArgc = tpmArgc + 1;
        }
    }

    //printf("TPM argv:\n");
    //for(int i = 0; i < tpmArgc; i++)
    //    printf(" %s\n", tpmArgv[i]);
    //printf("TPM argc: %d\n", tpmArgc);

    if(strcmp(tpmArgv[0],"sign") == 0)
        rc = sign(tpmArgc, tpmArgv);

    if (out_len >= 1)
        out[0] = rc;    
}
