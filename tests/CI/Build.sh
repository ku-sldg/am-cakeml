#!/bin/bash
set -eu


################ PATH VARS ################
# Assumes the following structure am-cakeml/tests/CI
CI_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TESTS_DIR="$(cd $CI_DIR && cd .. && pwd)"
REPO_ROOT="$(cd "$TESTS_DIR" && cd .. && pwd)"
################ END PATH VARS ################

if [[ "$REPO_ROOT" == */am-cakeml ]]; then
  # Move to build folder
  mkdir -p $REPO_ROOT/build
  cd $REPO_ROOT/build
  cmake ..
  make all
else
  echo "You are in $PWD, with the root set as $REPO_ROOT, but youre root should be 'am-cakeml'"
fi

