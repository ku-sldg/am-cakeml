# Demo Outline
## 1. Explain build process
* Prerequisites
* Build commands
* Testing successful install
## 2. Tour of code repo (directory structure)
* `/copland`:  core AM code
* `/system`:  crypto and comm
* `/util`:  bytestrings and json
* `/am`:  measurement utils
* `/apps`:  application-specific logic
    * serverClient
    * test suite
    * case
## 3.  Live Demo
### Setup

* Open 4 terminals (A,B,C,D)
    * A=   `/build`
    * B=   `/apps/serverClient`
    * C=   `/apps/serverClient/demo`
    * D=   `/apps/serverClient`
        
* Start server in terminal B
    * `sudo ../../build/server 5000 5`

### File Measurement

1. Run client in terminal A:  file measurement
    * `./client localhost fileMeas`
1. Observe contents of `hashTest.txt` in terminal D
    * `cat hashTest.txt`
1.  Launch attack on `hashTest.txt` from terminal C
    * `./modFile.sh`
    * Modifies contents of `hashTest.txt`
1.  Observe contents of `hashTest.txt` in terminal D
    * `cat hashTest.txt`
1.  Run client in terminal A:  file measurement
    * `./client localhost fileMeas`
    *  Appraisal fails with a "Bad hash value"
1.  Repair hashTest.txt from terminal C
    * `./repairFile.sh`
1. Re-Run client in terminal A:  file measurement
    * `./client localhost fileMeas`
    * Appraisal succeeds
### Directory Measurement
1.  Observe contents of testDir in terminal D
    * `cd testDir; cat 1.txt; ...`
1. Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
1. Launch attack modifying testDir/1.txt from terminal C
    * `./modDir.sh`
    * Modifies contents of `testDir/1.txt`
1. Observe contents of testDir/1.txt in terminal D
    * \<navigate to testDir> --> `cat 1.txt`
1. Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
    *  Appraisal fails with a "Bad hash value"
1.  Repair `testDir/1.txt` from terminal C
    * `repairDir.sh`
1.  Re-Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
    * Appraisal succeeds
1.  Launch extra file attack from terminal C
    * `./modDir2.sh`
    * Adds a trojan file called `extrabad.txt` to `testDir/dir2/`
1.  Observe contents of `testDir/dir2/` in terminal D
    * `cd dir2; ls; cat extrabad.txt`
1. Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
    *  Appraisal fails with a "Bad hash value"
1.  Repair `testDir/dir2/` from terminal C
    * `./repairDir2.sh`
1.  Re-Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
    * Appraisal succeeds
1.  Launch attack removing `testDir/1.txt` from terminal C
    * `./modDir3.sh`
1.  Observe contents of `testDir/` in terminal D
    * `cd ..; ls`
1. Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
    *  Appraisal fails with a "Bad hash value"
1.  Repair `testDir/` from terminal C
    * `./repairDir3.sh`
1.  Re-Run client in terminal A:  directory measurement
    * `./client localhost dirMeas`
    * Appraisal succeeds 

### Process Measurement
1.  Start good test process:
    *  navigate to `/apps/serverClient/testProc/good/`
    * `./testProc`
1.  Run client in terminal A: proc measurement
    * `./client localhost procMeas`
    *  Appraisal fails with a "Bad hash value" (Needs per-platform provisioning)
1.  Provision good test process
    * Copy/Paste golden hash value from Evidence to `apps/serverClient/ClientTest.sml` --> (val goldenHashProc)
    * Re-build client source in termainal A:  `make am`
1.  Run client in terminal A: proc measurement
    * `./client localhost procMeas`
    *  Appraisal succeeds
1.  Launch attack on testProc
    * terminate good testProc:  `ctl-c`
    * start bad testProc:
        *  navigate to `/apps/serverClient/testProc/bad/`
        * `./testProc`
1.  Run client in terminal A:  procFile measurement
    * `./client localhost procFileMeas`
    * Appraisal succeeds
      (good testProc executable unchanged)
1.  Run client in terminal A: proc measurement
    * `./client localhost procMeas`
    *  Appraisal fails with a "Bad hash value"
1.  Re-start good testProc
    *  navigate to `/apps/serverClient/testProc/good/`
    * `./testProc`
1.  Run client in terminal A: proc measurement
    * `./client localhost procMeas`
    *  Appraisal fails with a "Bad hash value" (bad testProc running)
1.  Kill bad testProc
    * `ctl-c`
1.  Run client in terminal A: proc measurement
    * `./client localhost procMeas`
    *  Appraisal succeeds (only good testProc running now)

