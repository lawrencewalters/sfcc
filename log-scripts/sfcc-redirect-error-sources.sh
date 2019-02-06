#!/bin/bash
echo "usage: FILES=*.log EXCLUDE=manifest.json sfcc-redirect-error-sources.sh"
echo "Top 100 missing redirects in $FILES, exluding $EXCLUDE"
grep -h com.demandware.beehive.core.capi.redirect.URLRedirectLocationProvider *.log|grep -v -e "manifest.json"|sed "s/.*com.demandware.beehive.core.capi.redirect.UR LRedirectLocationProvider .* Could not determine redirect location for: \(.*\)/\1/g"|sort|uniq -c|sort -r|head -n 100