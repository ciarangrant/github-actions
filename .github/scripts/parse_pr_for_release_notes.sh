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

TEXT_TO_PARSE=$(cat -)
START_MARKER="$1"
END_MARKER="$2"   # Optional
END_MARKER_PATTERN="" # Initialize END_MARKER_PATTERN to be empty by default

if [ -n "$END_MARKER" ]; then
  # Escape potential regex special characters in the raw end marker for safety.
  # This makes sure symbols like # . * + ? ( ) etc. are treated literally, not as regex.
  ESCAPED_END_MARKER=$(echo "$END_MARKER" | sed 's/[][\\.*+?$(){}^|]/\\&/g')
  
  # Convert the escaped end marker to lowercase and assign as the pattern
  END_MARKER_PATTERN=$(echo "$ESCAPED_END_MARKER" | tr '[:upper:]' '[:lower:]')
fi

RELEASE_NOTES=""
found_marker=false    

# Read TEXT_TO_PARSE line by line using process substitution and while loop
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
    # --- IMPORTANT FIX: Only perform regex match if END_MARKER_PATTERN is not empty ---
    if [ -n "$END_MARKER_PATTERN" ]; then 
      # The regex check: matches if trimmed line starts with the END_MARKER_PATTERN
      if [[ "$trimmed_line" =~ ^"$END_MARKER_PATTERN"(.*)$ ]]; then
        break # Exit the while loop if end marker is found
      fi
    fi
    # Append the current (original, untrimmed) line to RELEASE_NOTES
    # Use the original 'line' variable here to keep all original whitespace as required
    if [ -z "$RELEASE_NOTES" ]; then
      RELEASE_NOTES="$line" 
    else
      RELEASE_NOTES="$RELEASE_NOTES"$'\n'"$line" # Subsequent lines
    fi
  fi
done <<< "$TEXT_TO_PARSE" 

# Trim preceding and trailing blank lines
RELEASE_NOTES=$(echo "$RELEASE_NOTES" | sed -e '/./,$!d' | sed -e :a -e '/^\n*$/{$d;N;ba}')
# Check if the release notes are effectively blank eg only contain blank lines
if ! echo "$RELEASE_NOTES" | grep -qE '[^[:space:]]'; then
  RELEASE_NOTES=""
fi  

# Check if notes were found at all
if [ -z "$RELEASE_NOTES" ]; then
  echo "ERROR: No content found after '## Release Notes', '## Release Notes' not present, or only blank lines."
  FINAL_OUTPUT="" # Ensure it's an empty string if nothing valid was found
  exit 1
else
  FINAL_OUTPUT="$RELEASE_NOTES"
  # Otherwise, output the cleaned content
  echo "$FINAL_OUTPUT" 
  exit 0
fi
