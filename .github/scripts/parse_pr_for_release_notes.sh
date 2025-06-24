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

# Parameters
PR_BODY=$(cat -)
START_MARKER="$1" # Renamed to avoid conflict with internal Bash var
END_MARKER="$2"   # Optional: Renamed to avoid conflict

FULL_RELEASE_NOTES=""
found_marker=false    

# Read PR_BODY line by line using process substitution and while loop
# IFS= read -r line ensures correct line reading, preserving leading/trailing spaces
while IFS= read -r line; do
  trimmed_line=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/\r$//')
  # Convert to lower case so can ignore case on string to match
  trimmed_line=$(echo "$trimmed_line" | tr '[:upper:]' '[:lower:]')
  if [ "$trimmed_line" = "$START_MARKER" ]; then
    found_marker=true 
    continue
  fi

  if [ "$found_marker" = true ]; then
    if [[ "$trimmed_line" =~ ^"$END_MARKER"(.*)$ ]]; then
      # Found the start of an app-specific section, so stop collecting default notes.
      break # Exit the while loop
    fi
    # Append the current (original, untrimmed) line to FULL_RELEASE_NOTES
    # Use the original 'line' variable here to keep all original whitespace as required
    if [ -z "$FULL_RELEASE_NOTES" ]; then
      FULL_RELEASE_NOTES="$line" 
    else
      FULL_RELEASE_NOTES="$FULL_RELEASE_NOTES"$'\n'"$line" # Subsequent lines
    fi
  fi
done <<< "$PR_BODY" 

# Trim preceding and trailing blank lines
FULL_RELEASE_NOTES=$(echo "$FULL_RELEASE_NOTES" | sed -e '/./,$!d' | sed -e :a -e '/^\n*$/{$d;N;ba}')
# Check if the release notes are effectively blank eg only contain blank lines
if ! echo "$FULL_RELEASE_NOTES" | grep -qE '[^[:space:]]'; then
  FULL_RELEASE_NOTES=""
fi  

# Check if notes were found at all
if [ -z "$FULL_RELEASE_NOTES" ]; then
  echo "ERROR: No content found after '## Release Notes', '## Release Notes' not present, or only blank lines."
  FINAL_OUTPUT="" # Ensure it's an empty string if nothing valid was found
  exit 1
else
  FINAL_OUTPUT="$FULL_RELEASE_NOTES"
  # Otherwise, output the cleaned content
  echo "$FINAL_OUTPUT" 
  exit 0
fi
