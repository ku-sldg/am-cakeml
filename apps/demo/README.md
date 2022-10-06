# A client/server demo scenario #

## Build
To build this example, first start by building the CakeML Attestation
Manager by following the directions in the README
[here](https://github.com/ku-sldg/am-cakeml). To test a successful
install, from the `/build/` folder first run `make tests_tpm`.  Then
navigate to `../apps/tests/` and run `../../build/apps/tests/tests_tpm`.

Once completed, you are ready to configure and run the client/server demo. 

In the build folder you previously created, to build the client run `make clientdemo`, to build the server run `make serverdemo`, or build both with `make demo`.

## Run

The binaries will appear in the build directory, in `apps/demo` as `clientdemo` (for the Client executable) and `serverdemo` (for the Server executable). To test their interaction, you may run each executable from their respective directories:   `apps/demo/client` and `apps/demo/server`.  Remember to run the executables in the `build` directory as specified above (i.e. for the Client, run:  `../../../build/apps/demo/clientdemo <ini_file>`).

Example `.ini` files are in the `/apps/demo/<X>` directories (where `<X>` = `client` or `server`).  Use `example_server.ini` and `example_client.ini`, or create your own.

The server may be started at any time.  Use ctrl+c (SIGINT) to stop the server.

Before running the client, make sure the following services are installed and running:

### TPM 2.0 emulator service

See installation instructions at:  https://sourceforge.net/projects/ibmswtpm2/ 

### Ethereum Blockchain (local chain)

See installation instructions at:  https://github.com/ku-sldg/ku-mst/tree/master/doc/Private%20Blockchain%20Setup/how_to_setup_local_blockchain 

NOTE:  Be sure to document somewhere the relevant blockchain addresses you generated during the above config (these will be different between blockchain instances).  For now, these must be inserted in the cakeml source directly at:  `/stubs/IO_Stubs_extra.sml`.  Replace the existing strings called `healthRecordContract` and `userAddress` with your newly-generated addresses.  

For now, TRY TO AVOID adding `/stubs/IO_Stubs_extra.sml` to your github commits.  Some re-org is required to make these hard-coded values more modular or external to cakeml in the future. 

After the hard-coded addresses are added, re-build the demo with `make demo`.  Finally, start the server, TPM 2.0 emulator, and the Ethereum blockchain service.  Then run the client.  Successful output on the client may take a few seconds due to the blockchain delay.  It should eventually print results related to appraisal checks.




