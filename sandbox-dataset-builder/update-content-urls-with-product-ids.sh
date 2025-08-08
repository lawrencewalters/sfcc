#!/bin/bash -ex

# first build the mapping file from get-product-url-mappings.xslt
#
# this replaces product urls in content assets that don't work well with sandbox environments,
# like in titleist, they hardcode urls in nav content assets like /product/pro-v1/005PV1.html
# but in a sandbox, that breaks with multiple sites, so we replace those with the $url('Product-Show', 'pid', [actual product id])

input_file="$1"

# Loop through the mapping file
while IFS=":" read -r url product_id; do
  # Skip if either url or product_id is empty
  if [[ -n "$url" && -n "$product_id" ]]; then
    # Use sed to replace the page-url with the category-id
    sed -i "s|\"/$url\"|\"\$url('Product-Show','pid','$product_id')$\"|g" "$input_file"
  fi
done < data/url-to-product-id-mapping.txt 