This is an attestation manager server. It reads in JSON Copland terms over
a socket connection, evaluates them, and sends back the corresponding evidence term in the JSON representation.

When building for the odroid
    edit the assembly files ( server / client )
    and set the heap and stack sizes
    to 40 megabytes each
    maybe that number can be as high as 57
    but 40 works just fine
    30 is too small ( seg fault )

