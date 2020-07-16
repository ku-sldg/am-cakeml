// Author:  Adam Petz

#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include<dirent.h>
#include <stdlib.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/mman.h>
#include <string.h>

#include "meas.h"
//#include "sslcrypto.h"
//#include "sha512.h"
#include "debug.h"
#include "Hacl_Hash.h"

#define readFile_assert(cond,i) {if ((!cond)) { return i; }}

void doCompositeHash(const char *basePath, const char *excludePath, uint8_t **digest, uint8_t *message)
{ 
    if(!strcmp(basePath,excludePath)){
      return;
    }
  
    DEBUG_PRINT("Start of doCompositeHash: %s\n",basePath);
    char path[1000];
    struct dirent **namelist;
    int n;
    n = scandir(basePath, &namelist, NULL, alphasort);
    if(n == -1){
      return;
    }

    //DEBUG_PRINT("After first scandir() in doCompositeHash\n");
    
    int digest_len = 64;  // TODO:  make this a parameter, not hardcoded
    //digest = NULL;

    //DEBUG_PRINT("digest_len: %i\n",digest_len);
    
    for(int k = 0; k < n; k++){
      
      if (strcmp(namelist[k]->d_name, ".") != 0
	  && strcmp(namelist[k]->d_name, "..") != 0){

	if (namelist[k]->d_type == DT_REG) {

	  char newPath[1000];
	  strcpy(newPath, basePath);
	  strcat(newPath, "/");
	  strcat(newPath, namelist[k]->d_name);

	  DEBUG_PRINT("Adding hash for: %s\n",newPath);
	    
	  hash_file_contents(newPath, digest);

	  DEBUG_PRINT("HASH added for path: %s\n",newPath);
	  //DEBUG_PRINT("Diges len: %i\n",digest_len);
	    
	  memcpy(message+digest_len,(*digest),digest_len);
	  
          //#ifdef DOSSL
	  //digest_message((unsigned char *)message,digest_len*2, digest, &digest_len);
          //#else
	  //Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, (*digest));
	  Hacl_Hash_SHA2_hash_512(message, digest_len*2, (*digest));
	  //sha512((uint8_t *)message,digest_len*2,(uint8_t *)(*digest));
	  //#endif

	  DEBUG_PRINT("HASH FINAL added for path: %s\n",newPath);

	  memcpy(message,(*digest),digest_len);

	}
	// Construct new path from our base path
	strcpy(path, basePath);
	strcat(path, "/");
	strcat(path, namelist[k]->d_name);

	doCompositeHash(path,excludePath,digest,message);
      }
    } 
}

int hash_file_contents(const char *filename, uint8_t **digest) {
    size_t file_size = 0;
    void *file = NULL;

    int res = readFileContents(filename,&file,&file_size);
    readFile_assert((res == 0),res);
    printf("file_size after rfc(%s): %i\n",filename,file_size);
    printf("file contents after rfc: %s\n",file);

    Hacl_Hash_SHA2_hash_512((uint8_t *)file, (uint32_t)file_size, (*digest));

    int err = munmap(file, file_size);
    readFile_assert((err != -1),-4);

    return 0;






  /*
  DEBUG_PRINT("Start of hash_file_contents\n");
  char *fileContents;
  int contentsSize = 0;
  read_file_contents(fileName,&fileContents,&contentsSize);
  
  DEBUG_PRINT("Hashing File: \n%s\n",fileName);
  //DEBUG_PRINT("fileContents: \n%s\n",fileContents);
  //DEBUG_PRINT("contentsSize: \n%i\n",contentsSize);

  
  //#ifdef DOSSL
  //DEBUG_PRINT("Calling digest_message in hash_file_contents\n");
  //int digest_len;
  //digest_message((unsigned char *)fileContents, contentsSize, digest, &digest_len);
  //DEBUG_PRINT("After digest_message in hash_file_contents\n");
  //#else
  
  //DEBUG_PRINT("before sha512 in hash_file_contents\n");
  sha512((uint8_t *)fileContents,contentsSize,(*digest));
  //DEBUG_PRINT("after sha512 in hash_file_contents\n");
  //#endif
   
  if(fileContents){
    DEBUG_PRINT("Freeing fileContents\n");
    free(fileContents);
  }
  DEBUG_PRINT("End of hash_file_contents\n"); */
}

int readFileContents(const char *filename, void **file, size_t *file_size){
  int fd = open(filename, O_RDONLY);
  readFile_assert((fd != -1),-1);

  
  struct stat st;
  int err = stat(filename, &st);
  readFile_assert((err != -1),-2);
  size_t file_size_v = (size_t)st.st_size;
  //readFile_assert((file_size_v > 0),-3);
  if(file_size_v == 0){
    printf("zero length file\n");
    (*file) = 0;
  }
  else{
    (*file) = mmap((void *)NULL, file_size_v, PROT_READ, MAP_SHARED, fd, 0);
    //printf("file_size in rfc: %i\n",file_size_v);
    //printf("file contents in rfc: %s\n",(*file));
  }
  (*file_size) = file_size_v;
  return 0;
}



/*
// Adapted from here: https://stackoverflow.com/questions/174531/how-to-read-the-content-of-a-file-to-a-string-in-c
void read_file_contents(const char *fileName, char **buff, int *buff_len){
  char* buffer = 0;
  long length;
  FILE * f = fopen (fileName, "rb");

  if (f)
    {
      DEBUG_PRINT("\nOpened File Successfully: %s\n",fileName);
      fseek (f, 0, SEEK_END);
      length = ftell (f);
      //DEBUG_PRINT("\nbuffer Size: %li\n", length);
      fseek (f, 0, SEEK_SET);
      //DEBUG_PRINT("AFter SEEK_SET for file: \n%s\n",fileName);
      buffer = malloc (length);
      //DEBUG_PRINT("After malloc of length: \n%i\n",length);
      if (buffer)
	{
	  fread (buffer, 1, length, f);
	  //DEBUG_PRINT("After fread for: \n%s\n",fileName);
	}

    }
  else{
    DEBUG_PRINT("Failed to open file for reading: %s\n",fileName);
  }

  if (buffer)
    {
      //DEBUG_PRINT("\nbuffer Contents: %s\n", buffer);
      //DEBUG_PRINT("\nbuffer Size: %li\n", length);
      (*buff_len) = length;
      (*buff) = buffer;     
    }

  int fcloseRes = fclose (f);
  //DEBUG_PRINT("fclose result for filename: %s = %i\n",fileName,fcloseRes);
  DEBUG_PRINT("End of read_file_contents for: %s\n",fileName);
  // put return here to quell warnings of no return.
  // TODO: bad if contents empty?
  return;
}
*/
