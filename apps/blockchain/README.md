# An Example of a Server/Client That Talks to the Blockchain #

## Building for Unix-like OSes ##

Note that some parameters for the private Ethereum blockchain are hard coded
into the source code: the IP address and port (127.0.0.1:8543) of the
[geth](https://geth.ethereum.org/) RPC server and the public key address for the
unlocked admin account who will be the sender of the RPC requests
(`0x55500e...`). These values can be found in the functions
[`getHashDemo` on line 13 of `Client.sml`](Client.sml#L13) and
[`setHashDemo` on line 2 of `SetHash.sml`](SetHash.sml#L2). Change these as
needed. On the private Ethereum blockchain, there should be a contract with at
least two methods `getHash(uint256): bytes` and `setHash(uint256, bytes): void`
which get and set the hash values in a mapping stored by the contract. And at
the very least, the admin account for the blockchain should be allowed to read
and write to this mapping.

1. Go to the home directory for the project
   [am-cakeml](https://github.com/ku-sldg/am-cakeml/) and make the `./build/`
   directory with `mkdir build`.
2. Move into this new directory, `cd build`, and run `cmake ..` in order to
   generate the required Makefiles.
3. Build the blockchain example with `make blockchain`. The generated binaries
   will be places into `./build/`.
   * This will run three separate makes: `make blockchainServer` to build the
     server, `make blockchainClient` for the client, and
     `make blockchainSetHash` will create the program to store the golden hash
     value on the private blockchain.

## Running ##

1. Go to `./apps/blockchain/` and run the `test.sh` script, passing to it the 
   contract's address, e.g. `./test.sh 0xfeedface`.
2. What you should see:
   ```shell
   Starting the server...done.
   Set hash succeeded.
   Press enter to launch the client.
   Evaluating term:
   Att 1 (Lseq (Asp (Aspc Id 1 [testDir] )) (Asp Sig))

   Nonce:
   <nonce>

   Evidence recieved:
   G <signature> (U Id 1 [testDir] <golden hash> (N Id 0 <none> (Mt)))

   Appraisal succeeded (expected nonce and hash value; signature verified).
   ```
