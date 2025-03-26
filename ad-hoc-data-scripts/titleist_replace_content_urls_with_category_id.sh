#!/bin/bash -ex

# this is a script to replace the hardcoded category urls that appear in titleist navigation menus with what they should really be using in content assets - the $url('Search-Show', 'cgid', [actual category id]) so that the navigation links will work in sandbox environments that aren't based on "titleist.com" but instead a demandware on demand sandbox url with multiple sites
#
# run this like ./titleist_replace_content_urls_with_category_id.sh [input_file]
# where [input_file] is the file that contains export of the content library

input_file="$1"

# Loop through the mapping file
while IFS=":" read -r url category_id; do
  # Use sed to replace the page-url with the category-id
  sed -i "s|\"/*$url/*\"|\"\$url('Search-Show','cgid','$category_id')$\"|g" "$input_file"
done < mapping.txt