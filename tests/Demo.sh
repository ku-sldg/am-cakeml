#!/bin/bash
set -eu

# Function to display usage instructions
usage() {
  echo "Usage: $0 -t [cert|bg|parmut|filehash]"
  exit 1
}

TERM_TYPE=""
RUN_CLIENT=0

# Parse command-line arguments
while getopts "t:r" opt; do
  case ${opt} in
    t )
      TERM_TYPE=$OPTARG
      ;;
    r )
      RUN_CLIENT=1
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


if [[ $RUN_CLIENT -eq 0 ]]; then
  SERVER_MODE=""
else
  SERVER_MODE=" -r"
fi

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$TESTS_DIR/CI/Test.sh -t $TERM_TYPE $SERVER_MODE
