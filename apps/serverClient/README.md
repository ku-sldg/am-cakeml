# An example of a server/client pair #

The client sends a Copland term to measure a directory `testDir`.

## Build
Build the server with `make server`, the client with `make client`, or both with `make am`.

## Run
The binaries will appear in the build directory, in `apps/serverClient`. To test their interaction, you may run the server from the `apps/tests` source directory. Use the `example_server.ini` configuration file, or create your own.

The client may be run from any directory. Provide it with the `example_client.ini` configuration.

Use ctrl+c (SIGINT) to stop the server.
