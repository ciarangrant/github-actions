#!/bin/bash

# parse_pr_for_release_notes.sh
# Extracts text between a start marker and an optional end marker (exact string match).
#
# Usage: parse_pr_for_release_notes.sh <start_marker> [end_marker]
#
# If end_marker is provided, extraction stops at the line matching it.
# If not provided, extraction goes to the end of the file.
# Markers are matched case-insensitively after trimming.
#
# Outputs the extracted content to stdout.
# Exits with 0 if content is found, otherwise exist with 1



TEXT_TO_PARSE="$1"

echo "------------"
echo "$TEXT_TO_PARSE"
