#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
BUILT_AM=./build/COMPILED_AM
BUILT_CONC_MAN=./concrete_manifest.json
DEMO_FILES=../apps/ManifestCompiler/DemoFiles

# Server Variables
SERVER_FORM_MAN=$DEMO_FILES/Test_Server_FormMan.sml
SERVER_AM_LIB=$DEMO_FILES/Test_Server_Am_Lib.sml
SERVER_PRIV_KEY=$DEMO_FILES/Test_Server_PrivKey

# Client Variables
CLIENT_FORM_MAN=$DEMO_FILES/Test_FormMan.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib.sml
CLIENT_AM_LIB2=$DEMO_FILES/Test_Am_Lib2.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_compiler

  # First we need to compile the server, before starting tmux (to prevent race condition)
  $MAN_COMP -s -m $SERVER_FORM_MAN -l $SERVER_AM_LIB

  # First let us compile the server and then run it
  tmux new-session -d -s ServerProcess 'bash -i'
  tmux send-keys -t 0 "( $BUILT_AM -m $BUILT_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Setup tmux windows
  tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal
  
  # Now run the manifest compilations
  # Sending a chain of first AM comp, run, second AM comp, run
  tmux send-keys -t 1 \
    "($MAN_COMP -c -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB) && ($BUILT_AM -m $BUILT_CONC_MAN -k $CLIENT_PRIV_KEY) && ($MAN_COMP -c -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB2) && ($BUILT_AM -m $BUILT_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter
  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi
