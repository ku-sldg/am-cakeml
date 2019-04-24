# Status
Sockets should be working (both directions!) with the newest version of the compiler (`cake --version` = Wed Mar 27 10:58:50 2019 UTC).

# Licensing
The socket structure adapts file operations from the basis library to work with arbitrary file descriptors. Because code is adapted from the basis, the CakeML copyright notice is embedded as a comment into `SocketFFI.sml` where relevant.

# Misc
- If you need to terminate your program early, use Ctl+c. Using Ctl+z will result in the sockets not closing properly, and the program will likely fail to reacquire the socket port on the next execution (restarting fixes the issue).
- An alternative version is available [here](https://github.com/Gaj7/cakeml_sockets/tree/cleanup), which sort of models how the socket implementation would look if it were integrated into the basis library.
