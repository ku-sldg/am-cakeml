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

SERVER_P0_EXE_NAME=TEST_SERVER_AM_P0_EXE
SERVER_P1_EXE_NAME=TEST_SERVER_AM_EXE

SERVER_P0_CONC_MAN=$SERVER_P0_FORM_MAN #$DEMO_FILES/concrete_Manifest_P0.json
SERVER_P1_CONC_MAN=$SERVER_P1_FORM_MAN #$DEMO_FILES/concrete_Manifest_P1.json

# Client Variables
CLIENT_FORM_MAN=$DEMO_FILES/FormalManifest_P0.json
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Kim.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_EXE_NAME=TEST_CLIENT_AM_ONE_EXE

CLIENT_TERM_FILE=$DEMO_FILES/ClientCvmTermKim.sml

CLIENT_P0_CONC_MAN=$SERVER_P0_FORM_MAN #$DEMO_FILES/concrete_Manifest_P0.json

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_generator
  make manifest_compiler


  # First, generate the formal manifests
  $MAN_GEN -om $DEMO_FILES -t "kim"

  #sleep 2

  # Now compile the servers, before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_P1_EXE_NAME -om $SERVER_P1_CONC_MAN -m $SERVER_P1_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P0_EXE_NAME -om $SERVER_P0_CONC_MAN -m $SERVER_P0_FORM_MAN -l $SERVER_AM_LIB
  
  
  BUILT_SERVER_AM_ONE=./build/$SERVER_P1_EXE_NAME
  BUILT_SERVER_AM_P0=./build/$SERVER_P0_EXE_NAME

  BUILT_CLIENT_AM=./build/$CLIENT_EXE_NAME

  # Setup tmux windows
  tmux new-session -d -s ServerProcess 'bash -i'
  tmux split-window -v 'bash -i'
  tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal

   # Start the P0 server
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_P0 -m $SERVER_P0_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P1 server
  tmux send-keys -t 1 "( $BUILT_SERVER_AM_ONE -m $SERVER_P1_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Now manifest compile and run the Client AM
  # Sending a chain of first AM comp, then run AM
  tmux send-keys -t 2 \
    "($MAN_COMP -c $CLIENT_TERM_FILE -o $CLIENT_EXE_NAME -om $CLIENT_P0_CONC_MAN -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB) && \
     ($BUILT_CLIENT_AM -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter

  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

