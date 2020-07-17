#ifndef __MEAS_H__
#define __MEAS_H__

int doCompositeHash(const char *basePath, const char *excludePath, uint8_t *digest, uint8_t *message);
int hash_file_contents(const char *filename, uint8_t *digest);
void * mapFileContents(const char *filename, size_t *file_size);

#endif
