#!/bin/bash
# set -x

# Load paths from paths.env (see ../README.md)
source "$(dirname "$0")/paths.env"

for library_dir in "$SOURCE_DIR"/libraries/*/; do
	library_name="${library_dir%/}"
	library_name="${library_name##*/}"
    echo "Processing library: $library_name"
	library_file="${library_dir}library.xml"
	[[ -f "$library_file" ]] || continue

    ../sandbox-dataset-builder/clean-xml.sh "$library_file" "$library_name-cleaned.xml"

    # get all fully offline content assets
	java -jar "$SAXON_JAR" -s:"$library_name-cleaned.xml" -xsl:"$SCRIPT_DIR/content-offline-report.xslt" \
		| grep -Ev "2025|2026" > "../data/${library_name}-offline-content-report.csv"

    # get all asset ids
    grep -oE 'content-id="[^"]+"' "$library_name-cleaned.xml" | sed -E 's/content-id="([^"]+)"/\1/' | sort -u > "../data/${library_name}-all-content-ids.txt"

    # find those not referenced by slots
    for site_dir in "$SOURCE_DIR"/sites/*/; do
        site_name="${site_dir%/}"
        site_name="${site_name##*/}"
        echo "Processing site: $site_name"
        slots_file="${site_dir}slots.xml"
        [[ -f "$slots_file" ]] || continue

        slots_ids_file="../data/${library_name}-${site_name}-slot-content-ids.txt"

        # Extract all content IDs referenced by this site's slots.
        grep -oE 'content-id="[^"]+"' "$slots_file" \
            | sed -E 's/content-id="([^"]+)"/\1/' \
            | sort -u > "$slots_ids_file"

        # Remove IDs referenced by this site's slots from the library ID list.
        comm -23 "../data/${library_name}-all-content-ids.txt" "$slots_ids_file" > "../data/${library_name}-all-content-ids.tmp"
        mv "../data/${library_name}-all-content-ids.tmp" "../data/${library_name}-all-content-ids.txt"

    done

done
