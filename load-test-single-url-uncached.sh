#!/bin/bash

# Load the hostname from dw.json using jq
DW_JSON_PATH="$(dirname "$0")/dw.json"
if [ ! -f "$DW_JSON_PATH" ]; then
    echo "Error: dw.json file not found at $DW_JSON_PATH"
    exit 1
fi

HOSTNAME=$(jq -r '.hostname' "$DW_JSON_PATH")
if [ -z "$HOSTNAME" ] || [ "$HOSTNAME" == "null" ]; then
    echo "Error: hostname not found in dw.json"
    exit 1
fi

PASSWORD=$(jq -r '.storefrontPassword' "$DW_JSON_PATH")
if [ -z "$PASSWORD" ] || [ "$PASSWORD" == "null" ]; then
    echo "Error: storefrontPassword not found in dw.json"
    exit 1
fi

# Define the base URL using the hostname from dw.json
BASE_URL="https://${HOSTNAME}/s/kjus/us/en/men/golf/rain-and-wind/"

# Define the username and password for basic authentication
USERNAME="storefront"  # Replace with your username

# Define the user agent string for Chrome
USER_AGENT="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/113.0.0.0 Safari/537.36"

# Array to store response times
response_times=()

# Loop to make 100 requests
for i in {1..100}; do
    # Generate a random query parameter value
    RANDOM_VALUE=$RANDOM

    # Construct the full URL with the random query parameter
    FULL_URL="${BASE_URL}?randomParam=${RANDOM_VALUE}"

    # Time the curl request and capture the response time
    START_TIME=$(date +%s%3N)
    curl -s -A "$USER_AGENT" -u "$USERNAME:$PASSWORD" "$FULL_URL" > /dev/null  # Add basic authentication
    END_TIME=$(date +%s%3N)

    # Calculate the response time in milliseconds
    RESPONSE_TIME=$((END_TIME - START_TIME))
    response_times+=($RESPONSE_TIME)

    echo "Request $i: $FULL_URL - Response Time: ${RESPONSE_TIME}ms"

    # Optional: Add a short delay between requests to avoid overwhelming the server
    sleep 0.1
done

# Calculate average response time
total=0
for time in "${response_times[@]}"; do
    total=$((total + time))
done
average=$((total / 100))

# Calculate median response time
sorted_times=($(printf '%s\n' "${response_times[@]}" | sort -n))
median=${sorted_times[49]}  # 50th element (0-indexed) for 100 requests

# Calculate 95th percentile response time
percentile_index=$((95 * 100 / 100 - 1))  # 95th percentile index
percentile=${sorted_times[$percentile_index]}

# Print results
echo "Average Response Time: ${average}ms"
echo "Median Response Time: ${median}ms"
echo "95th Percentile Response Time: ${percentile}ms"