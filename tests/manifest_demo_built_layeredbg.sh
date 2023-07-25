#!/bin/bash

# Common Variables
DEMO_FILES=../tests/DemoFiles/LayeredBG

# Server Variables
SERVER_P1_FORM_MAN=$DEMO_FILES/FormalManifest_P1.sml
SERVER_P2_FORM_MAN=$DEMO_FILES/FormalManifest_P2.sml
SERVER_P3_FORM_MAN=$DEMO_FILES/FormalManifest_P3.sml
SERVER_P4_FORM_MAN=$DEMO_FILES/FormalManifest_P4.sml
SERVER_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cache.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

SERVER_P1_CONC_MAN=$DEMO_FILES/concrete_Manifest_P1.json
SERVER_P2_CONC_MAN=$DEMO_FILES/concrete_Manifest_P2.json
SERVER_P3_CONC_MAN=$DEMO_FILES/concrete_Manifest_P3.json
SERVER_P4_CONC_MAN=$DEMO_FILES/concrete_Manifest_P4.json

SERVER_P1_EXE_NAME=TEST_SERVER_P1_AM_EXE
SERVER_P2_EXE_NAME=TEST_SERVER_P2_AM_EXE
SERVER_P3_EXE_NAME=TEST_SERVER_P3_AM_EXE
SERVER_P4_EXE_NAME=TEST_SERVER_P4_AM_EXE

# Client Variables
CLIENT_P0_FORM_MAN=$DEMO_FILES/FormalManifest_P0.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cache.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_P0_CONC_MAN=$DEMO_FILES/concrete_Manifest_P0.json

CLIENT_P0_EXE_NAME=TEST_CLIENT_AM_ONE_EXE


CLIENT_P0_TERM_FILE=$DEMO_FILES/ClientCvmTermLayeredBGP0.sml


if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
 
  BUILT_SERVER_AM_P1=$DEMO_FILES/$SERVER_P1_EXE_NAME
  BUILT_SERVER_AM_P2=$DEMO_FILES/$SERVER_P2_EXE_NAME
  BUILT_SERVER_AM_P3=$DEMO_FILES/$SERVER_P3_EXE_NAME
  BUILT_SERVER_AM_P4=$DEMO_FILES/$SERVER_P4_EXE_NAME

  BUILT_CLIENT_AM_P0=$DEMO_FILES/$CLIENT_P0_EXE_NAME


  # First let us compile the server and then run it
  tmux new-session -d -s ServerProcess 'bash -i'
 
  tmux split-window -v 'bash -i'
  tmux split-window -v 'bash -i'
  tmux split-window -v 'bash -i'
  # Setup tmux windows
  tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal

  tmux send-keys -t 0 "($BUILT_SERVER_AM_P1 -m $SERVER_P1_CONC_MAN -k $SERVER_PRIV_KEY )" Enter
  tmux send-keys -t 1 "($BUILT_SERVER_AM_P2 -m $SERVER_P2_CONC_MAN -k $SERVER_PRIV_KEY )" Enter
  tmux send-keys -t 2 "($BUILT_SERVER_AM_P3 -m $SERVER_P3_CONC_MAN -k $SERVER_PRIV_KEY )" Enter
  tmux send-keys -t 3 "($BUILT_SERVER_AM_P4 -m $SERVER_P4_CONC_MAN -k $SERVER_PRIV_KEY )" Enter
  
  # Now run the manifest compilations
  # Sending a chain of first AM comp, run, second AM comp, run
  tmux send-keys -t 4 "sleep 1 && ($BUILT_CLIENT_AM_P0 -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY -cs)" Enter
  #tmux send-keys -t 3 "($BUILT_CLIENT_AM_P0 -m $CLIENT_P0_CONC_MAN -k $CLIENT_PRIV_KEY -cs)" Enter

  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi
