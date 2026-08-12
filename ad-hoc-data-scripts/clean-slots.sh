#!/bin/bash
set -x

# Load paths from paths.env (see ../README.md)
source "$(dirname "$0")/paths.env"

for site_dir in "$SOURCE_DIR"/sites/*/; do
	site_name="${site_dir%/}"
	site_name="${site_name##*/}"
    echo "Processing site: $site_name"
	slots_file="${site_dir}slots.xml"
	[[ -f "$slots_file" ]] || continue
	java -jar "$SAXON_JAR" -s:"$slots_file" -xsl:"$SCRIPT_DIR/slots-disabled-configs-report.xslt" \
		| grep -Ev "25|26" > "../data/${site_name}-slots-disabled-configs-report.csv"

done
