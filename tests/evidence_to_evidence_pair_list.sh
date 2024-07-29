#!/bin/bash
set -eu

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GENERATED=$TESTS_DIR/DemoFiles/Generated
TOP_PLC="P3"

# Function to display usage instructions
usage() {
  echo "Usage: $0 -f <json_evidence_file> -o <output_file>"
  exit 1
}

JSON_EVID_FILE=""
EVID_PAIR_FILE=""

# Parse command-line arguments
while getopts "f:o:" opt; do
  case ${opt} in
    f )
      JSON_EVID_FILE=$OPTARG
      ;;
    o )
      EVID_PAIR_FILE=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$JSON_EVID_FILE" || -z "$EVID_PAIR_FILE" ]]; then
  usage
  exit 1
fi

# Check if the JSON file exists
if [[ ! -f "$JSON_EVID_FILE" ]]; then
  echo "JSON file not found: $JSON_EVID_FILE"
  exit 1
fi

# Read JSON data from the file
JSON_EVID_DATA=$(cat "$JSON_EVID_FILE")

# Build Evidnce_Plc_list JSON structure
EVID_FILE_JSON="{ \"Evidence_Plc_list\": [ [$JSON_EVID_DATA, \"$TOP_PLC\" ] ] }" 

# Write to generated temporarily
echo $EVID_FILE_JSON > $EVID_PAIR_FILE
