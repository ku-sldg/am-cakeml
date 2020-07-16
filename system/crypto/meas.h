#ifndef __MEAS_H__
#define __MEAS_H__

void doCompositeHash(const char *basePath, const char *excludePath, uint8_t *digest, uint8_t *message);
int hash_file_contents(const char *filename, uint8_t *digest);
int readFileContents(const char *filename, void **file, size_t *file_size);

#endif
