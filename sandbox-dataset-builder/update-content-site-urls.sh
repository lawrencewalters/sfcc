#!/bin/bash -ex

# replace www.titleist.ca with a sandbox url

input_file="$1"

# Loop through the mapping file
while IFS=":" read -r url sandbox_url; do
  # Skip if either url or sandbox_url is empty
  if [[ -n "$url" && -n "$sandbox_url" ]]; then
    # Use sed to replace the page-url with the category-id
    sed -i "s|$url|$sandbox_url|g" "$input_file"
  fi
done < data/url-to-sandbox-mapping.txt 