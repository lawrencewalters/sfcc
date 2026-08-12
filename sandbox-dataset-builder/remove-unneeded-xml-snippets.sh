#!/bin/bash

set -euo pipefail

usage() {
    echo "Usage: $0 <xml-file>"
    echo "  Looks for the file in the current directory first, then uses the provided path."
    exit 1
}

resolve_target_file() {
    local input_file="$1"

    if [ -f "./$input_file" ]; then
        echo "./$input_file"
    elif [ -f "$input_file" ]; then
        echo "$input_file"
    else
        echo "Error: file not found: $input_file" >&2
        exit 1
    fi
}

remove_snippet() {
    local target_file="$1"
    local snippet="$2"

    SNIPPET="$snippet" perl -0pi -e 's/\Q$ENV{SNIPPET}\E//g' "$target_file"
}

if [ "$#" -ne 1 ]; then
    usage
fi

input_file="$1"
target_file="$(resolve_target_file "$input_file")"

snippets=()


# Snippet 1: store flags block
snippets+=("$(cat <<'EOF'
        <store-force-price-flag>false</store-force-price-flag>
        <store-non-inventory-flag>false</store-non-inventory-flag>
        <store-non-revenue-flag>false</store-non-revenue-flag>
        <store-non-discountable-flag>false</store-non-discountable-flag>
EOF
)")

# Snippet 2: available flag
snippets+=("$(cat <<'EOF'
        <available-flag>true</available-flag>
EOF
)")

# Snippet 3: pinterest/facebook/store-attributes block
snippets+=("$(cat <<'EOF'
        <pinterest-enabled-flag>false</pinterest-enabled-flag>
        <facebook-enabled-flag>false</facebook-enabled-flag>
        <store-attributes>
            <force-price-flag>false</force-price-flag>
            <non-inventory-flag>false</non-inventory-flag>
            <non-revenue-flag>false</non-revenue-flag>
            <non-discountable-flag>false</non-discountable-flag>
        </store-attributes>
EOF
)")

snippets+=("$(cat <<'EOF'
        <ean/>
        <upc/>
        <unit/>
EOF
)")

snippets+=("$(cat <<'EOF'
        <page-attributes/>
EOF
)")

for snippet in "${snippets[@]}"; do
    remove_snippet "$target_file" "$snippet"
done

echo "Updated XML file: $target_file"
