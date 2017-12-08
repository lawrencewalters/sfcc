#!/bin/bash
echo "Top 10 errors in $FILES:"
grep -h -e "^\[" $FILES |  sed -e "s/^\([^|]*|\)\{2\}\([^|]*\)|\([^|]*\)|[^|]*|\([^ ]*\)\([^-]*\) \([^ ]* \)\{6\}\(.*\)/\2 \3 \5 \7/g" | sort | uniq -c | sort -r | head -n 10