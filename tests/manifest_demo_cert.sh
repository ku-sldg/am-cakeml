#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
#BUILT_AM=./build/COMPILED_AM
#BUILT_CONC_MAN=./concrete_manifest.json
DEMO_FILES=../apps/ManifestCompiler/DemoFiles

# Server Variables
SERVER_P1_FORM_MAN=$DEMO_FILES/FormalManifest_P1.sml
SERVER_P2_FORM_MAN=$DEMO_FILES/FormalManifest_P2.sml
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

SERVER_P1_CONC_MAN=$DEMO_FILES/concrete_Manifest_P1.json
SERVER_P2_CONC_MAN=$DEMO_FILES/concrete_Manifest_P2.json

SERVER_P1_EXE_NAME=TEST_SERVER_P1_AM_EXE
SERVER_P2_EXE_NAME=TEST_SERVER_P2_AM_EXE

# Client Variables
#CLIENT_FORM_MAN=$DEMO_FILES/Test_FormMan.sml
CLIENT_FORM_MAN=$DEMO_FILES/FormalManifest_P0.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib.sml
CLIENT_CONC_MAN=$DEMO_FILES/concrete_Manifest_P0.json



#CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
#CLIENT_AM_LIB2=$DEMO_FILES/Test_Am_Lib2.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_ONE_EXE_NAME=TEST_CLIENT_AM_ONE_EXE
#CLIENT_TWO_EXE_NAME=TEST_CLIENT_AM_TWO_EXE

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_compiler

  # First we need to compile the server(s), before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_P1_EXE_NAME -om $SERVER_P1_CONC_MAN -m $SERVER_P1_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P2_EXE_NAME -om $SERVER_P2_CONC_MAN -m $SERVER_P2_FORM_MAN -l $SERVER_AM_LIB

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi
