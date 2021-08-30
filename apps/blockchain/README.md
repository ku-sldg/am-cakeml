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

1. Go to the projects root directory, then head to `./build/apps/blockchain/`
   and run the `test.sh` script, passing to it the contract's address, e.g.
   `./test.sh 0xfeedface`.
2. What you should see:
   ```shell
   Starting the server...done.
   Set hash succeeded.
   Press enter to launch the client.
   Evaluating term:
   Att 1 (Lseq (Asp (Aspc Id 1 [testDir] )) (Asp Sig))

   Nonce:
   <nonce>

   Evidence received:
   G <signature> (U Id 1 [testDir] <golden hash> (N Id 0 <none> (Mt)))

   Appraisal succeeded (expected nonce and hash value; signature verified).
   ```

# A Certificate Authority for Key Authorization #

An example of a key authorization protocol where the server/CA certifies a key
for the client by signing the key and encrypting it with the client's public
key. The client sends a request in the form of their own public identifier and
the key to be authorized, receives the encrypted signature from the CA,
decrypts it, and now has the signature to pass along with the key to any third
party.

## Building for Unix-like OSes ##

1. Go to the home directory for the project
   [am-cakeml](https://github.com/ku-sldg/am-cakeml/) and make the `./build/`
   directory with `mkdir build`.
2. Move into this new directory, `cd build`, and run `cmake ..` in order to
   generate the required Makefiles.
3. Build the blockchain example with `make blockchainCAAll`. The generated
   binaries will be places into `./build/`.
   * This will run two separate makes: `make blockchainCA` to build the
     CA and `make blockchainCAClient` to make the client demo.

## Running ##

1. Go to the projects root directory, then head to `./build/apps/blockchain/`.
2. Run `./blockchainCA 5001 5 &` to start the server listening on port 5001 with
   at most 5 concurrent connections.
3. Run `./blockchainCAClient 5001` to run the client demo.
4. You should see an output like the following:
   ```shell
   <== Added client public key to CAs list.
       Got CAs public encryption key.
       Computed alias: 1444B1...000000
   ==> Received alias: 1444B1...000000
       Signature: D80137...A2B30D
       Encrypted signature: BD4E26...019CC1
   <== Encrypted signature: BD4E26...019CC1
       Signature: D80137...A2B30D
       Got CAs public signing key.
       Signature check: True
   ```
