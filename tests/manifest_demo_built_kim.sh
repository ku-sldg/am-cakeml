#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
MAN_GEN=./apps/ManifestGenerator/manGen_demo
DEMO_FILES=../tests/DemoFiles/Kim

# Server Variables
SERVER_FORM_MAN=$DEMO_FILES/FormalManifest_P1.sml
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_Kim.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

SERVER_EXE_NAME=TEST_SERVER_AM_EXE

SERVER_P1_CONC_MAN=$DEMO_FILES/concrete_Manifest_P1.json

# Client Variables
CLIENT_FORM_MAN=$DEMO_FILES/FormalManifest_P0.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Kim.sml
CLIENT_AM_LIB2=$DEMO_FILES/Test_Am_Lib_Kim2.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_ONE_EXE_NAME=TEST_CLIENT_AM_ONE_EXE

CLIENT_TERM_FILE=$DEMO_FILES/ClientCvmTermKim.sml

CLIENT_P0_CONC_MAN=$DEMO_FILES/concrete_Manifest_P0.json

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  
  BUILT_SERVER_AM_ONE=$DEMO_FILES/$SERVER_EXE_NAME
  
  BUILT_CLIENT_AM_ONE=$DEMO_FILES/$CLIENT_ONE_EXE_NAME

  # First let us compile the server and then run it
  tmux new-session -d -s ServerProcess 'bash -i'
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_ONE -m $SERVER_P1_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Setup tmux windows
  tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal
  
  # Now run the manifest compilations
  # Sending a chain of first AM comp, run, second AM comp, run
  tmux send-keys -t 1 "sleep 1 && ($BUILT_CLIENT_AM_ONE -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter 
  
  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

