#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
MAN_GEN=./apps/ManifestGenerator/manGen_demo
DEMO_FILES=../tests/DemoFiles/LayeredBG

# Server Variables
SERVER_P0_FORM_MAN=$DEMO_FILES/FormalManifest_P0.json
SERVER_P1_FORM_MAN=$DEMO_FILES/FormalManifest_P1.json
SERVER_P2_FORM_MAN=$DEMO_FILES/FormalManifest_P2.json
SERVER_P3_FORM_MAN=$DEMO_FILES/FormalManifest_P3.json
SERVER_P4_FORM_MAN=$DEMO_FILES/FormalManifest_P4.json
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_LayeredBG.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

SERVER_P0_CONC_MAN=$SERVER_P0_FORM_MAN #$DEMO_FILES/concrete_Manifest_P0.json
SERVER_P1_CONC_MAN=$SERVER_P1_FORM_MAN #$DEMO_FILES/concrete_Manifest_P1.json
SERVER_P2_CONC_MAN=$SERVER_P2_FORM_MAN #$DEMO_FILES/concrete_Manifest_P2.json
SERVER_P3_CONC_MAN=$SERVER_P3_FORM_MAN #$DEMO_FILES/concrete_Manifest_P3.json
SERVER_P4_CONC_MAN=$SERVER_P4_FORM_MAN #$DEMO_FILES/concrete_Manifest_P4.json

SERVER_P0_EXE_NAME=TEST_SERVER_P0_AM_EXE
SERVER_P1_EXE_NAME=TEST_SERVER_P1_AM_EXE
SERVER_P2_EXE_NAME=TEST_SERVER_P2_AM_EXE
SERVER_P3_EXE_NAME=TEST_SERVER_P3_AM_EXE
SERVER_P4_EXE_NAME=TEST_SERVER_P4_AM_EXE

# Client Variables
CLIENT_P0_FORM_MAN=$DEMO_FILES/FormalManifest_P0.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_LayeredBG.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_P0_CONC_MAN=$SERVER_P0_FORM_MAN #$DEMO_FILES/concrete_Manifest_P0.json

CLIENT_P0_EXE_NAME=TEST_CLIENT_AM_ONE_EXE

CLIENT_P0_TERM_FILE=$DEMO_FILES/ClientCvmTermLayeredBGP0.sml


if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_generator
  make manifest_compiler

  # First, generate the formal manifests
  $MAN_GEN -om $DEMO_FILES -t "lbg"

  # First we need to compile the AMs, before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_P3_EXE_NAME -om $SERVER_P3_CONC_MAN -m $SERVER_P3_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P4_EXE_NAME -om $SERVER_P4_CONC_MAN -m $SERVER_P4_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P0_EXE_NAME -om $SERVER_P0_CONC_MAN -m $SERVER_P0_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P1_EXE_NAME -om $SERVER_P1_CONC_MAN -m $SERVER_P1_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P2_EXE_NAME -om $SERVER_P2_CONC_MAN -m $SERVER_P2_FORM_MAN -l $SERVER_AM_LIB

  $MAN_COMP -c $CLIENT_P0_TERM_FILE -o $CLIENT_P0_EXE_NAME -om $CLIENT_P0_CONC_MAN -m $CLIENT_P0_FORM_MAN -l $CLIENT_AM_LIB

  BUILT_SERVER_AM_P0=./build/$SERVER_P0_EXE_NAME
  BUILT_SERVER_AM_P1=./build/$SERVER_P1_EXE_NAME
  BUILT_SERVER_AM_P2=./build/$SERVER_P2_EXE_NAME
  BUILT_SERVER_AM_P3=./build/$SERVER_P3_EXE_NAME
  BUILT_SERVER_AM_P4=./build/$SERVER_P4_EXE_NAME

  BUILT_CLIENT_AM_P0=./build/$CLIENT_P0_EXE_NAME


  # Setup tmux windows
  tmux new-session -d -s ServerProcess 'bash -i'

  tmux split-window -v 'bash -i' # Pane 0
  tmux split-window -h 'bash -i' # Pane 1
  tmux split-window -v 'bash -i' # Pane 2
  tmux split-window -h 'bash -i' # Pane 3
  tmux split-window -v 'bash -i' # Pane 4
  tmux select-layout even-horizontal

  # Start the P0 server
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_P0 -m $SERVER_P0_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P1 server
  tmux send-keys -t 1 "( $BUILT_SERVER_AM_P1 -m $SERVER_P1_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P2 server
  tmux send-keys -t 2 "($BUILT_SERVER_AM_P2 -m $SERVER_P2_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P3 server
  tmux send-keys -t 3 "($BUILT_SERVER_AM_P3 -m $SERVER_P3_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P4 server
  tmux send-keys -t 4 "($BUILT_SERVER_AM_P4 -m $SERVER_P4_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Start the P0 client
  tmux send-keys -t 5 "($BUILT_CLIENT_AM_P0 -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY -cs)" Enter

  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

