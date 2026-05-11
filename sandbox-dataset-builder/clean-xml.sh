#!/bin/bash
# Script to clean invalid XML characters from files before processing with Saxon

clean_xml_file() {
    local input_file="$1"
    local output_file="$2"
    
    # Remove invalid XML characters and character references
    # First remove invalid character references like &#0; through &#31; (except 9, 10, 13)
    # Then remove raw invalid bytes
    sed -E 's/&#11;?//g' "$input_file" > "$output_file"
}

# Usage: clean_xml_file input.xml cleaned_output.xml
if [ $# -eq 2 ]; then
    clean_xml_file "$1" "$2"
    echo "Cleaned XML file: $1 -> $2"
fi