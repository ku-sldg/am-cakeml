#!/bin/bash

# This file was produced in part by using the chatGPT tool.

filename="$1"

if [[ ! -f "$filename" ]]; then
    echo "File not found!"
    exit 1
fi

function_name=$(basename "$filename" | sed 's/\..*//')
output_file="$function_name-ini.sml"

echo "fun $function_name () = \"\" ^" > "$output_file"

while IFS= read -r line || [[ -n "$line" ]]; do
    # check if line starts with semicolon, if so ignore it
    if [[ "$line" == ";"* ]]; then
    continue
    fi
    # remove anything after the first
    # semicolon, if present
    line=$(echo "$line" | sed 's/;.*//')

    # escape quotation marks
    line=$(echo "$line" | sed 's/"/\\"/g')

    # if the line is less than 80
    # characters, output it as a single
    # chunk
    if [[ ${#line} -le 80 ]]; then
        echo "\"$line\n\" ^" >> "$output_file"
    else
        # break line into 80 character chunks
        # and output as a CakeML function
        while [[ ${#line} -gt 80 ]]; do
            chunk="${line:0:80}"
            echo -n "\"$chunk\"" >> "$output_file"
            echo " ^" >> "$output_file"
            line="${line:80}"
        done

        echo "\"$line\n\" ^" >> "$output_file"
    fi

done < "$filename"

# print closing quotes for the function
echo "\"\";" >> "$output_file"

echo "Output written to $output_file"

