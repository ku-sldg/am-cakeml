#!/bin/bash
set -eu

if [[ "$PWD" == */am-cakeml/tests ]]; then
  repoRoot=$(dirname "$PWD")
  # Move to build folder
  mkdir -p $repoRoot/build
  cd $repoRoot/build
  cmake ..
  make all
else
  echo "You are not in the 'am-cakeml/tests' directory"
fi

