#!/bin/bash
set -eu

# Function to display usage instructions
usage() {
  echo "Usage: $0 -t [cert|bg|parmut|filehash]"
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
  exit 1
fi

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
$TESTS_DIR/CI/Test.sh -t $TERM_TYPE
