#!/bin/bash
set -eu

TESTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

GENERATED=$TESTS_DIR/DemoFiles/Generated
TOP_PLC="P0"

# Function to display usage instructions
usage() {
  echo "Usage: $0 -f <json_term_file> -o <output_file>"
  exit 1
}

JSON_TERM_FILE=""
TERM_PAIR_FILE=""

# Parse command-line arguments
while getopts "f:o:" opt; do
  case ${opt} in
    f )
      JSON_TERM_FILE=$OPTARG
      ;;
    o )
      TERM_PAIR_FILE=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$JSON_TERM_FILE" || -z "$TERM_PAIR_FILE" ]]; then
  usage
  exit 1
fi

# Check if the JSON file exists
if [[ ! -f "$JSON_TERM_FILE" ]]; then
  echo "JSON file not found: $JSON_TERM_FILE"
  exit 1
fi

# Read JSON data from the file
JSON_TERM_DATA=$(cat "$JSON_TERM_FILE")

# Build Term_Plc_list JSON structure
TERM_FILE_JSON="{ \"Term_Plc_list\": [ [$JSON_TERM_DATA, \"$TOP_PLC\" ] ] }" 

# Write to generated temporarily
echo $TERM_FILE_JSON > $TERM_PAIR_FILE
