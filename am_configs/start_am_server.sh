#!/bin/bash
set -eu

# Function to display usage instructions
usage() {
  echo "Usage Error: $0 -m <path-to-ManifestPX.json> -u <server-uuid>  (i.e. $0 -m attest/ManifestP0.json -u 127.0.0.1:5000)"
  exit 1
}

if [ -z ${ASP_BIN+x} ]; then
  echo "Variable 'ASP_BIN' is not set" 
  echo "Run: 'export ASP_BIN=<path-to-asp_binaries>'"
  exit 1
fi

if [ -z ${AM_COMMS_BIN+x} ]; then
  echo "Variable 'AM_COMMS_BIN' is not set" 
  echo "Run: 'export AM_COMMS_BIN=<path-to-am_comms_binary>'"
  exit 1
fi

MANIFEST_PATH=""
SERVER_UUID=""

if [ -z ${AM_ROOT+x} ]; then
  echo "WARNING:  Variable 'AM_ROOT' is not set" 
  echo "Trying to use relative path instead:  'AM_ROOT=../../am-cakeml'"
  AM_ROOT=../../am-cakeml
fi

echo ""

# Parse command-line arguments
while getopts "m:u:" opt; do
  case ${opt} in
    m )
      MANIFEST_PATH=$OPTARG
      ;;
    u )
      SERVER_UUID=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$MANIFEST_PATH" ]]; then
  usage
  exit 1
fi

# Check if all required arguments are provided
if [[ -z "$SERVER_UUID" ]]; then
  usage
  exit 1
fi

$AM_ROOT/build/bin/attestation_manager -m $MANIFEST_PATH -u $SERVER_UUID -b $ASP_BIN --comms $AM_COMMS_BIN

echo "Starting AM on IP:port $SERVER_UUID for manifest at path $MANIFEST_PATH ..."