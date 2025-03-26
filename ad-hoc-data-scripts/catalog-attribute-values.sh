#!/bin/sh
# for a given attribute-id, find the unique values given a catalog
# usage: ./catalog-attribute-values.sh <attribute-id> <catalog>
grep "attribute-id=\"$1\"" "$2" | sort | uniq