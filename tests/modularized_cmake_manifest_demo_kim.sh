#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
MAN_GEN=./apps/ManifestGenerator/manGen_demo
DEMO_FILES=../tests/DemoFiles/Kim

# Server Variables
SERVER_P0_FORM_MAN=$DEMO_FILES/FormalManifest_P0.json

SERVER_P1_FORM_MAN=$DEMO_FILES/FormalManifest_P1.json
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_Kim.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

#SERVER_P0_EXE_NAME=TEST_SERVER_AM_P0_EXE
SERVER_P1_EXE_NAME=TEST_SERVER_AM_EXE

# Client Variables
CLIENT_FORM_MAN=$SERVER_P0_FORM_MAN
CLIENT_AM_LIB=$SERVER_AM_LIB
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_EXE_NAME=TEST_CLIENT_AM_EXE

CLIENT_TERM_FILE_JSON=$DEMO_FILES/ClientCvmTermKim.json

MANGEN_TERMS_FILE=$DEMO_FILES/ServerPlcTermsKim.json


if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  cmake .. -DAPP_TO_BUILD=generator
  make manifest_generator
  cmake .. -DAPP_TO_BUILD=compiler
  make manifest_compiler


  # First, generate the formal manifests
  $MAN_GEN -om $DEMO_FILES -t $MANGEN_TERMS_FILE

  #sleep 2

  # Now compile the servers, before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_P1_EXE_NAME -m $SERVER_P1_FORM_MAN -l $SERVER_AM_LIB
  #$MAN_COMP -s -o $SERVER_P0_EXE_NAME -m $SERVER_P0_FORM_MAN -l $SERVER_AM_LIB
  
  
  BUILT_SERVER_AM_ONE=./build/$SERVER_P1_EXE_NAME
  #BUILT_SERVER_AM_P0=./build/$SERVER_P0_EXE_NAME

  BUILT_CLIENT_AM=./build/$CLIENT_EXE_NAME

  # Setup tmux windows
  tmux new-session -d -s ServerProcess 'bash -i'
  tmux split-window -v 'bash -i'
  #tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal

   # Start the P0 server
  #tmux send-keys -t 0 "( $BUILT_SERVER_AM_P0 -m $SERVER_P0_FORM_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P1 server
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_ONE -m $SERVER_P1_FORM_MAN -k $SERVER_PRIV_KEY )" Enter

  # Now manifest compile and run the Client AM
  # Sending a chain of first AM comp, then run AM
  tmux send-keys -t 1 \
    "($MAN_COMP -c -o $CLIENT_EXE_NAME -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB) && \
     ($BUILT_CLIENT_AM -m $CLIENT_FORM_MAN -k $CLIENT_PRIV_KEY -t $CLIENT_TERM_FILE_JSON )" Enter

  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

