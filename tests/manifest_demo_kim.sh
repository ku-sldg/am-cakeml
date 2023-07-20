#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
MAN_GEN=./apps/ManifestGenerator/manGen_demo
#BUILT_AM=./build/COMPILED_AM
#BUILT_CONC_MAN=./concrete_manifest.json
DEMO_FILES=../apps/ManifestCompiler/DemoFiles

# Server Variables
#SERVER_FORM_MAN=$DEMO_FILES/Test_Server_FormMan.sml
#SERVER_AM_LIB=$DEMO_FILES/Test_Server_Am_Lib.sml
SERVER_FORM_MAN=$DEMO_FILES/FormalManifest_P1.sml
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

SERVER_EXE_NAME=TEST_SERVER_AM_EXE

SERVER_P1_CONC_MAN=$DEMO_FILES/concrete_Manifest_P1.json

# Client Variables
CLIENT_FORM_MAN=$DEMO_FILES/FormalManifest_P0.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
#CLIENT_FORM_MAN=$DEMO_FILES/Test_FormMan.sml
#CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib.sml
#CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
CLIENT_AM_LIB2=$DEMO_FILES/Test_Am_Lib_Cert2.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_ONE_EXE_NAME=TEST_CLIENT_AM_ONE_EXE
CLIENT_TWO_EXE_NAME=TEST_CLIENT_AM_TWO_EXE

CLIENT_TERM_FILE=$DEMO_FILES/ClientCvmTermKim.sml

# SERVER_P1_TERMS_FILE=$DEMO_FILES/ServerCvmTermsCert.sml

CLIENT_P0_CONC_MAN=$DEMO_FILES/concrete_Manifest_P0.json

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_generator
  make manifest_compiler


  # First, generate the formal manifests
  $MAN_GEN -om "" -t "kim"

  # First we need to compile the server, before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_EXE_NAME -om $SERVER_P1_CONC_MAN -m $SERVER_FORM_MAN -l $SERVER_AM_LIB

  BUILT_SERVER_AM_ONE=./build/$SERVER_EXE_NAME

  BUILT_CLIENT_AM_ONE=./build/$CLIENT_ONE_EXE_NAME
  BUILT_CLIENT_AM_TWO=./build/$CLIENT_TWO_EXE_NAME


  # First let us compile the server and then run it
  tmux new-session -d -s ServerProcess 'bash -i'
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_ONE -m $SERVER_P1_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Setup tmux windows
  tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal
  
  # Now run the manifest compilations
  # Sending a chain of first AM comp, run, second AM comp, run
  tmux send-keys -t 1 \
    "($MAN_COMP -c $CLIENT_TERM_FILE -o $CLIENT_ONE_EXE_NAME -om $CLIENT_P0_CONC_MAN -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB) && \
     ($BUILT_CLIENT_AM_ONE -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter # && \
     #($MAN_COMP -c $CLIENT_TERM_FILE -o $CLIENT_TWO_EXE_NAME -om $CLIENT_P0_CONC_MAN -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB2) && \
     #($BUILT_CLIENT_AM_TWO -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter
  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi
