#!/bin/bash
set -eu

################ PATH VARS ################
# Assumes the following structure am-cakeml/tests/CI
CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(cd $CI_DIR && cd .. && pwd)"
REPO_ROOT="$(cd "$TESTS_DIR" && cd .. && pwd)"
BUILD_DIR="$REPO_ROOT/build"
BUILD_BIN="$BUILD_DIR/bin"
################ END PATH VARS ################

# Function to display usage instructions
usage() {
  echo "Usage: $0 -t [cert|cert_appr|bg|parmut|filehash] (-h (headless)) [-a <path-to-asps>] -s (for only checking phrase send, otherwise checks for successful appraisal)"
  exit 1
}

TERM_TYPE=""
HEADLESS=0
SEND=0

# Parse command-line arguments
while getopts "t:ha:s" opt; do
  case ${opt} in
    t )
      TERM_TYPE=$OPTARG
      ;;
    h )
      HEADLESS=1
      ;;
    a )
      ASP_BIN=$OPTARG
      ;;
    s )
      SEND=1
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$TERM_TYPE" ]]; then
  usage
  exit 1
fi

CLIENT_AM_ARGS=""
if [[ $SEND -eq 1 ]]; then
  CLIENT_AM_ARGS="--send"
else
  CLIENT_AM_ARGS="--appr"
fi

if [[ "$TERM_TYPE" == "layered_bg" ]]; then
  echo "Layered BG is not yet supported..."
  usage
  exit 0
fi

PIDS=()

# Function to kill all background processes
kill_background_processes() {
  if [[ $HEADLESS -ne 0 ]]; then
    echo -e "\nKilling background processes...\n"
    kill ${PIDS[@]} || true
  fi
}

# Trap to ensure background processes are killed on script exit
trap kill_background_processes EXIT

# Common Variables
IP=localhost
PORT=5000
TERM_GEN=$BUILD_BIN/term_to_json
EV_GEN=$BUILD_BIN/evidence_to_json
MAN_GEN=$BUILD_BIN/manifest_generator
AM_EXEC=$BUILD_BIN/attestation_manager
CLIENT_AM_EXEC=$BUILD_BIN/client_am

if [ -z ${ASP_BIN+x} ]; then
  echo "Variable 'ASP_BIN' is not set" 
  echo "Run: 'export ASP_BIN=<path-to-asps>' or"
  usage
  exit 1
fi

# General Path Vars
DEMO_FILES=$TESTS_DIR/DemoFiles
GENERATED=$DEMO_FILES/Generated

# Reusable Variables
TEST_GLOBAL_CONTEXT=$DEMO_FILES/Test_Global_Context.json
TEST_ATT_SESS=$DEMO_FILES/Test_Session.json
FULL_ATT_SESS=$GENERATED/Full_Session.json
SESS_REPLACE_VAR="\"\$\$FILL_IN_CONTEXT\$\$\""

# Specific Variables
TERM_FILE="$GENERATED/$TERM_TYPE.json"
TERM_PAIR_LIST="$GENERATED/TermPairList.json"

EV_FILE="$GENERATED/$TERM_TYPE-Evidence.json"
EVID_PAIR_LIST="$GENERATED/EvidPairList.json"

# Clean and rebuild generated dir
rm -rf $GENERATED
mkdir -p $GENERATED

# Replace $$Test_Global_Context.json$$ variable in TEST_ATT_SESS with the value within the file TEST_GLOBAL_CONTEXT
sed -e "/$SESS_REPLACE_VAR/{
  s/$SESS_REPLACE_VAR//g
  r $TEST_GLOBAL_CONTEXT
}" $TEST_ATT_SESS > $FULL_ATT_SESS


if [[ "$REPO_ROOT" == */am-cakeml ]]; then
  # Move to build folder
  mkdir -p $BUILD_DIR
  cd $BUILD_DIR

  # Generate the terms file
  $TERM_GEN -t $TERM_TYPE -o $TERM_FILE

  # Generate the term pair list
  $TESTS_DIR/term_to_term_pair_list.sh -f $TERM_FILE -o $TERM_PAIR_LIST

  # Generate the evidence file
  $EV_GEN -t $TERM_TYPE -o $EV_FILE -g $TEST_GLOBAL_CONTEXT

  # Generate the evidence pair list
  $TESTS_DIR/evidence_to_evidence_pair_list.sh -f $EV_FILE -o $EVID_PAIR_LIST

  # First, generate the manifests
  $MAN_GEN -cm $TEST_GLOBAL_CONTEXT -t $TERM_PAIR_LIST -e $EVID_PAIR_LIST -o $GENERATED

  PIDS=()

  # If not headless, start tmux
  if [[ $HEADLESS -eq 0 ]]; then
    tmux new-session -d -s ServerProcess 'bash -i'
  fi
  
  manifest_pattern='Manifest_P.\.json' # regex to find "Manifest_PX.json" in full path to manifest
  MAN_REL_PATH="" # Relative filepath string: "Manifest_PX.json"
  MAN_PLC_STR=""  # Place string:  "X" in "Manifest_PX.json"
  # Generate an AM for each manifest
  for MANIFEST in $GENERATED/Manifest_*.json; do
    if [[ $MANIFEST =~ $manifest_pattern ]]; then 
      MAN_REL_PATH=${BASH_REMATCH[0]}
      MAN_PLC_STR=${MAN_REL_PATH:10:1}
    else 
      echo "Failed to find 'Manifest_PX.json' pattern in generated manifest file"
      exit 1
    fi

    # Increment the running port
    CUR_PORT=$((PORT + $MAN_PLC_STR))
    if [[ $HEADLESS -eq 0 ]]; then
      tmux new-window -t ServerProcess -n "AM_$MAN_PLC_STR" "bash -i"

      tmux send-keys -t ServerProcess:AM_$MAN_PLC_STR "echo \"Starting AM on port $CUR_PORT for manifest $MANIFEST\"" C-m

      tmux send-keys -t ServerProcess:AM_$MAN_PLC_STR "$AM_EXEC -m $MANIFEST -b $ASP_BIN -u \"$IP:$CUR_PORT\"" C-m
    else
      echo "Starting AM on port $CUR_PORT for manifest $MANIFEST"
      # Start the AM in the background and store its PID
      $AM_EXEC -m $MANIFEST -b $ASP_BIN -u "$IP:$CUR_PORT" &
      PIDS+=($!)
    fi
  done
  
  # Now send the request, on the very last window
  if [[ $HEADLESS -eq 0 ]]; then
    tmux new-window -t ServerProcess -n "Client"

    tmux send-keys -t ServerProcess:Client "sleep 1 && $CLIENT_AM_EXEC -t $TERM_FILE -s $FULL_ATT_SESS $CLIENT_AM_ARGS" C-m
      
    tmux attach-session -d -t ServerProcess
  else
    sleep 1 
    $CLIENT_AM_EXEC -t $TERM_FILE -s $FULL_ATT_SESS $CLIENT_AM_ARGS > $GENERATED/output_resp.json
    # $TESTS_DIR/send_term_req.sh -h $IP -p $PORT -f $TERM_FILE -s $FULL_ATT_SESS > $GENERATED/output_resp.json
    # We need this to be the last line so that the exit code is whether or not we found success
    if [[ $SEND -eq 1 ]]; then
      grep "SUCCESS: Copland Phrase Executed Successfully!" $GENERATED/output_resp.json
    else
      grep "Appraisal Summary: PASSED" $GENERATED/output_resp.json
    fi
  fi
else
  echo "You are in $PWD, with the root set as $REPO_ROOT, but youre root should be 'am-cakeml'"
fi

