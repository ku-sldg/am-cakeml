#!/bin/bash

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GENERATED=$TESTS_DIR/DemoFiles/Generated
TOP_PLC="P0"
TERM_PAIR_FILE=$GENERATED/TermPairList.json

# Function to display usage instructions
usage() {
  echo "Usage: $0 -f <json_term_file>"
  exit 1
}

# Parse command-line arguments
while getopts "f:" opt; do
  case ${opt} in
    f )
      JSON_TERM_FILE=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$JSON_TERM_FILE" ]]; then
  usage
fi

# Check if the JSON file exists
if [[ ! -f "$JSON_TERM_FILE" ]]; then
  echo "JSON file not found: $JSON_TERM_FILE"
  exit 1
fi

# Read JSON data from the file
JSON_TERM_DATA=$(cat "$JSON_TERM_FILE")

# Send JSON data to the specified host and port
TERM_FILE_JSON="{ \"Term_Plc_list\": [ [$JSON_TERM_DATA, \"$TOP_PLC\" ] ] }" 

# Write to generated temporarily
echo $TERM_FILE_JSON > $TERM_PAIR_FILE
