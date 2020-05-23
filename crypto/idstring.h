#ifndef __IDSTRING_H__
#define __IDSTRING_H__

#include <stdint.h>

/** Construct the SHA-512 digest of the given message.
 *
 * @param [in] msg The message to copy.
 *
 * @param [in] size The size of the message, in bytes.
 *
 * @param [out] digest A pointer to 64 bytes of space to store the
 * copied output message.
 */

void idstring(const uint8_t *msg,
            const uint64_t size,
            uint8_t *digest);

#endif
