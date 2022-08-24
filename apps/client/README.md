# An example of a server/client pair #

The client sends a Copland term to measure a directory `testDir`.

## Build
To build this example, first start by building the CakeML Attestation Manager by following the directions in the README [here](https://github.com/ku-sldg/am-cakeml). To test a successful install, make sure you navigate to `apps/tests/` and run `../../build/apps/tests/tests`.

Once completed, you are ready to run the server/client example. 

In the build folder you previously created, to build the server run `make server`, to build the client run `make client`, or build both with `make am`.

## Run

The binaries will appear in the build directory, in `apps/serverClient`. To test their interaction, you may run the server from the `apps/tests` source directory. Use the `example_server.ini` configuration file, or create your own.

From the test directory, the command line invocation may read `../../build/apps/serverClient/server ../../apps/serverClient/example_server.ini` for the server. Start the server first then run a simmilar command for the client. 

The client may be run from any directory. Provide it with the `example_client.ini` configuration.

Use ctrl+c (SIGINT) to stop the server.
