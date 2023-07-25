#!/bin/bash

# Common Variables
MAN_COMP=./apps/ManifestCompiler/manComp_demo
MAN_GEN=./apps/ManifestGenerator/manGen_demo
#BUILT_AM=./build/COMPILED_AM
#BUILT_CONC_MAN=./concrete_manifest.json
DEMO_FILES=../tests/DemoFiles/Cert

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
#CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib.sml
CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
CLIENT_CONC_MAN=$DEMO_FILES/concrete_Manifest_P0.json



#CLIENT_AM_LIB=$DEMO_FILES/Test_Am_Lib_Cert.sml
#CLIENT_AM_LIB2=$DEMO_FILES/Test_Am_Lib2.sml
CLIENT_PRIV_KEY=$DEMO_FILES/Test_PrivKey

CLIENT_ONE_EXE_NAME=TEST_CLIENT_AM_ONE_EXE
#CLIENT_TWO_EXE_NAME=TEST_CLIENT_AM_TWO_EXE




CLIENT_TERM_FILE=$DEMO_FILES/ClientCvmTermCert.sml

#SERVER_P1_TERMS_FILE=$DEMO_FILES/ServerCvmTermsCert.sml
#SERVER_P2_TERMS_FILE=$DEMO_FILES/ServerCvmTermsCert.sml




if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  cd $repoRoot/build
  # Make targets
  make manifest_generator
  make manifest_compiler

  # First, generate the formal manifests
  $MAN_GEN -om $DEMO_FILES -t "cert"

  # First we need to compile the server(s), before starting tmux (to prevent race condition)
  $MAN_COMP -s -o $SERVER_P1_EXE_NAME -om $SERVER_P1_CONC_MAN -m $SERVER_P1_FORM_MAN -l $SERVER_AM_LIB
  $MAN_COMP -s -o $SERVER_P2_EXE_NAME -om $SERVER_P2_CONC_MAN -m $SERVER_P2_FORM_MAN -l $SERVER_AM_LIB

  BUILT_SERVER_AM_P1=./build/$SERVER_P1_EXE_NAME
  BUILT_SERVER_AM_P2=./build/$SERVER_P2_EXE_NAME

  BUILT_CLIENT_AM_ONE=./build/$CLIENT_ONE_EXE_NAME
  #BUILT_CLIENT_AM_TWO=./build/$CLIENT_TWO_EXE_NAME




  # First let us compile the server and then run it
  tmux new-session -d -s ServerProcess 'bash -i'
  tmux send-keys -t 0 "( $BUILT_SERVER_AM_P1 -m $SERVER_P1_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  tmux split-window -v 'bash -i'

  tmux send-keys -t 1 "( $BUILT_SERVER_AM_P2 -m $SERVER_P2_CONC_MAN -k $SERVER_PRIV_KEY )" Enter

  # Setup tmux windows
  tmux split-window -h 'bash -i'
  tmux select-layout even-horizontal
  
  # Now run the manifest compilations
  # Sending a chain of first AM comp, run, second AM comp, run
  tmux send-keys -t 2 \
    "($MAN_COMP -c $CLIENT_TERM_FILE -o $CLIENT_ONE_EXE_NAME -om $CLIENT_CONC_MAN -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB) && \
     ($BUILT_CLIENT_AM_ONE -m $CLIENT_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter
     #($BUILT_CLIENT_AM_ONE -m $CLIENT_CONC_MAN -k $CLIENT_PRIV_KEY -cs)" Enter
     
    # && \
    # ($MAN_COMP -c -o $CLIENT_TWO_EXE_NAME -m $CLIENT_FORM_MAN -l $CLIENT_AM_LIB2) && \
    # ($BUILT_CLIENT_AM_TWO -m $BUILT_CONC_MAN -k $CLIENT_PRIV_KEY)" Enter
  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

