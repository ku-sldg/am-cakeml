#!/bin/bash
set -eu

# Function to display usage instructions
usage() {
  echo "Usage: $0 -t [cert|bg|parmut|layered_bg]"
  exit 1
}

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

if [[ "$TERM_TYPE" == "layered_bg" ]]; then
  echo "Layered BG is not yet supported..."
  usage
  exit 0
fi

PIDS=()

# Function to kill all background processes
kill_background_processes() {
    echo -e "\nKilling background processes...\n"
    kill ${PIDS[@]} || true
    # for pid in ${PIDS[@]}; do
    #   echo "Killing process with PID: $pid"
    #   if kill $pid; then
    #       echo "Killed process with PID: $pid"
    #   else
    #       echo "Failed to kill process with PID: $pid"
    #   fi
    # done
}

# Trap to ensure background processes are killed on script exit
trap kill_background_processes EXIT


TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Common Variables
IP=localhost
PORT=5000
TERM_GEN=./bin/term_to_json
MAN_GEN=./bin/manifest_generator
AM_EXEC=./bin/attestation_manager

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

# Clean and rebuild generated dir
rm -rf $GENERATED
mkdir -p $GENERATED

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  mkdir -p $repoRoot/build
  cd $repoRoot/build
  cmake ..

  # Generate the terms file
  $TERM_GEN -t $TERM_TYPE -o $TERM_FILE

  # Generate the term pair list
  $TESTS_DIR/term_to_term_pair_list.sh -f $TERM_FILE

  # First, generate the manifests
  $MAN_GEN -t $GENERATED/TermPairList.json -e $DEMO_FILES/Evid_List.json -o $GENERATED

  PIDS=()
  
  # Generate an AM for each manifest
  for MANIFEST in $GENERATED/Manifest_*.json; do
    # Start the AM in the background and store its PID
    $AM_EXEC -m $MANIFEST -l $TEST_AM_LIB -b $ASP_BIN -k $TEST_PRIVKEY &
    PIDS+=($!)
  done
  
  # Now send the request, on the very last window
  sleep 1 
  $TESTS_DIR/send_term_req.sh -h $IP -p $PORT -f $TERM_FILE > $GENERATED/output.out
  # We need this to be the last line so that the exit code is whether or not we found success
  grep "\"SUCCESS\":true" $GENERATED/output.out
else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

