#!/bin/bash

# extract_section.sh
# Extracts text between a start marker and an optional end marker (exact string match).
#
# Usage: extract_section.sh <text_to_search_file> <start_marker> [end_marker]
#
# If end_marker is provided, extraction stops at the line matching it.
# If not provided, extraction goes to the end of the file.
# Markers are matched case-insensitively after trimming.
#
# Outputs the extracted content to stdout.
# Exits with 0 if content is found, 1 if start marker not found or content is blank.

# Input parameters
PR_BODY="$1"
START_MARKER="$2" # Renamed to avoid conflict with internal Bash var
END_MARKER="$3"   # Optional: Renamed to avoid conflict

echo "A"
echo "$PR_BODY"
echo "B"
echo "$START_MARKER"
echo "C"
echo "$END_MARKER"

echo "______ START ________"
