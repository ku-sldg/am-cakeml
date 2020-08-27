# Demo Outline
1. Explain build process
    * Prerequisites
    * Build commands
    * Testing successful install
1. Tour of code repo (directory structure)
    * /copland:  core AM code
    * /system:  crypto and comm
    * /util:  bytestrings and json
    * /am:  measurement utils
    * /apps:  application-specific logic
        * serverClient
        * test suite
        * case
1. Live Demo
    1. Open 4 terminals (A,B,C,D)
        * A=   /build
        * B=   /apps/serverClient
        * C=   /apps/serverClient
        * D=   /apps/serverClient
        
    1. Start server in terminal B
        * `sudo ../../build/server 5000 5`
    1. Run client in terminal A:  file measurement
        * `./client localhost fileMeas`



