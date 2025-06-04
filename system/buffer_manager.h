#ifndef BUFFER_MANAGER_H
#define BUFFER_MANAGER_H

void get_buffer_by_id(const int buffer_id, const long length, char *out_buffer);

int set_new_buffer(const long length, char *const buffer);

void ffiget_buffer_by_id(const char *in, const long in_length, char *ret, const long ret_length);

#endif