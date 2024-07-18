#!/bin/bash
set -eu

# Function to display usage instructions
usage() {
  echo "Usage: $0 -t [filehash] (the client am only supports filehash right now)"
  exit 1
}

TERM_TYPE=""

# Parse command-line arguments
while getopts "t:" opt; do
  case ${opt} in
    t )
      TERM_TYPE=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$TERM_TYPE" ]]; then
  usage
fi

if [[ "$TERM_TYPE" != "filehash" ]]; then
  echo "Only filehash is supported by the client AM right now..."
  usage
  exit 1
fi

if [[ "$TERM_TYPE" == "layered_bg" ]]; then
  echo "Layered BG is not yet supported..."
  usage
  exit 1
fi

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Common Variables
IP=localhost
PORT=5000
TERM_GEN=./bin/term_to_json
EV_GEN=./bin/evidence_to_json
MAN_GEN=./bin/manifest_generator
AM_EXEC=./bin/attestation_manager
CLIENT_AM_EXEC=./bin/client_am

if [ -z ${ASP_BIN+x} ]; then
  echo "Variable 'ASP_BIN' is not set" 
  echo "Run: 'export ASP_BIN=<path-to-asps>'"
  exit 1
fi

# General Path Vars
DEMO_FILES=$TESTS_DIR/DemoFiles
GENERATED=$DEMO_FILES/Generated

# Reusable Variables
TEST_PRIVKEY=$DEMO_FILES/Test_PrivKey
TEST_AM_LIB=$DEMO_FILES/Test_AM_Lib.json

# Specific Variables
TERM_FILE="$GENERATED/$TERM_TYPE.json"
EV_FILE="$GENERATED/$TERM_TYPE-Evidence.json"

# Clean and rebuild generated dir
rm -rf $GENERATED
mkdir -p $GENERATED

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  mkdir -p $repoRoot/build
  cd $repoRoot/build
  cmake ..

  # Make targets
  make all

  # Generate the terms file
  $TERM_GEN -t $TERM_TYPE -o $TERM_FILE

  # Generate the term pair list
  $TESTS_DIR/term_to_term_pair_list.sh -f $TERM_FILE

  # Generate the evidence file
  $EV_GEN -t $TERM_TYPE -o $EV_FILE

  # Generate the evidence pair list
  $TESTS_DIR/evidence_to_evidence_pair_list.sh -f $EV_FILE

  # First, generate the manifests
  $MAN_GEN -t $GENERATED/TermPairList.json -e $GENERATED/EvidencePairList.json -l $TEST_AM_LIB -o $GENERATED

  # Setup tmux windows
  tmux new-session -d -s ServerProcess 'bash -i'
  
  # Generate an AM for each manifest
  I=0
  for MANIFEST in $GENERATED/Manifest_*.json; do
    # Make window for it
    tmux split-window -v 'bash -i'
    tmux select-layout even-horizontal
    # Start the AM
    tmux send-keys -t $I "( $AM_EXEC -m $MANIFEST -l $TEST_AM_LIB -b $ASP_BIN -k $TEST_PRIVKEY )" Enter
    # Increment I
    I=$((I+1))
  done
  
  # Now send the request, on the very last window
  tmux send-keys -t $I "sleep 1 && $CLIENT_AM_EXEC" Enter

  tmux attach-session -d -t ServerProcess

else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

