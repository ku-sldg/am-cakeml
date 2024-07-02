#!/bin/bash

# Function to display usage instructions
usage() {
  echo "Usage: $0 -h <host> -p <port> -f <json_file>"
  exit 1
}

# Parse command-line arguments
while getopts "h:p:f:" opt; do
  case ${opt} in
    h )
      HOST=$OPTARG
      ;;
    p )
      PORT=$OPTARG
      ;;
    f )
      JSON_FILE=$OPTARG
      ;;
    * )
      usage
      ;;
  esac
done

# Check if all required arguments are provided
if [[ -z "$HOST" || -z "$PORT" || -z "$JSON_FILE" ]]; then
  usage
fi

# Check if the JSON file exists
if [[ ! -f "$JSON_FILE" ]]; then
  echo "JSON file not found: $JSON_FILE"
  exit 1
fi

# Read JSON data from the file
JSON_DATA=$(cat "$JSON_FILE")

# Send JSON data to the specified host and port
echo -e "$JSON_DATA" | nc $HOST $PORT
