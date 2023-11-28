#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
MAN_GEN=./apps/ManifestGenerator/manGen_demo
DEMO_FILES=../tests/DemoFiles/Cert

# Server Variables
SERVER_P0_FORM_MAN=$DEMO_FILES/FormalManifest_P0.json
SERVER_P1_FORM_MAN=$DEMO_FILES/FormalManifest_P1.json
SERVER_P2_FORM_MAN=$DEMO_FILES/FormalManifest_P2.json
SERVER_P3_FORM_MAN=$DEMO_FILES/FormalManifest_P3.json
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

#SERVER_P0_EXE_NAME=TEST_SERVER_P0_AM_EXE
SERVER_P1_EXE_NAME=TEST_SERVER_P1_AM_EXE
SERVER_P2_EXE_NAME=TEST_SERVER_P2_AM_EXE
SERVER_P3_EXE_NAME=TEST_SERVER_P3_AM_EXE

# Client Variables
CLIENT_FORM_MAN=$SERVER_P0_FORM_MAN
CLIENT_AM_LIB=$SERVER_AM_LIB

CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_EXE_NAME=TEST_CLIENT_AM_ONE_EXE

CLIENT_TERM_FILE_JSON=$DEMO_FILES/ClientCvmTermCert.json

MANGEN_TERMS_FILE=$DEMO_FILES/ServerPlcTermsCert.json
MANGEN_EVS_FILE=$DEMO_FILES/ServerPlcEvsCert.json


if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_generator
  make manifest_compiler

  # First, generate the formal manifests
  $MAN_GEN -om $DEMO_FILES -t $MANGEN_TERMS_FILE -e $MANGEN_EVS_FILE

  # First we need to compile the server(s), before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_P3_EXE_NAME -m $SERVER_P3_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P1_EXE_NAME -m $SERVER_P1_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P2_EXE_NAME -m $SERVER_P2_FORM_MAN -l $SERVER_AM_LIB

  #BUILT_SERVER_AM_P0=./build/$SERVER_P0_EXE_NAME
  BUILT_SERVER_AM_P1=./build/$SERVER_P1_EXE_NAME
  BUILT_SERVER_AM_P2=./build/$SERVER_P2_EXE_NAME
  BUILT_SERVER_AM_P3=./build/$SERVER_P3_EXE_NAME

  BUILT_CLIENT_AM_ONE=./build/$CLIENT_EXE_NAME


  # Setup tmux windows
  tmux new-session -d -s ServerProcess 'bash -i'

  tmux split-window -v 'bash -i'
  tmux split-window -v 'bash -i'
  tmux split-window -v 'bash -i'
  #tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal

  # Start the P3 server
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_P3 -m $SERVER_P3_FORM_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P1 server
  tmux send-keys -t 1 "( $BUILT_SERVER_AM_P1 -m $SERVER_P1_FORM_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P2 server
  tmux send-keys -t 2 "( $BUILT_SERVER_AM_P2 -m $SERVER_P2_FORM_MAN -k $SERVER_PRIV_KEY )" Enter
  
  # Now manifest compile and run the Client AM
  # Sending a chain of first AM comp, then run AM
  tmux send-keys -t 3 \
    "($MAN_COMP -c -o $CLIENT_EXE_NAME -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB) && \
     ($BUILT_CLIENT_AM_ONE -m $CLIENT_FORM_MAN -k $CLIENT_PRIV_KEY -t $CLIENT_TERM_FILE_JSON )" Enter

  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

