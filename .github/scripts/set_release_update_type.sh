#!/bin/bash

# set_release_update_type.sh
# Checks the format of the release notes texts and extracts the update type from it
#
# Usage: set_release_update_type.sh
#
# Outputs the extracted content to stdout.
# Exits with 0 if a valid update type is found, otherwise exits with 1

RELEASE_NOTES=$(cat -)
UNRELEASED_CHANGES=$(echo "$RELEASE_NOTES" | grep -m 1 "^## \[Unreleased\]") >&2

if [ -z "$UNRELEASED_CHANGES" ] # If UNRELEASED_CHANGES is empty
then
  echo "Release Note doesn't contain unreleased changes" >&2
  exit 1
else
  echo "Release Note contains unreleased changes: $UNRELEASED_CHANGES" >&2
fi

UPDATE_TYPE_REGEX='^## \[Unreleased\] - (MAJOR|MINOR|PATCH)' # Capture MAJOR|MINOR|PATCH in group 1
if [[ $UNRELEASED_CHANGES =~ $UPDATE_TYPE_REGEX ]]
then
  UPDATE_TYPE="${BASH_REMATCH[1]}" # Set UPDATE_TYPE to group 1 content
  echo "Release Note contains update type ${UPDATE_TYPE}" >&2
else
  echo "Release Note doesn't contain update type" >&2
  exit 1
fi

# new check to ensure release note isnt just the [Unreleased] line
VALID_CONTENT="false"
echo "AAAAAAAAA" >&2
while IFS= read -r line; do
    echo "OK"
    #trimmed_line_for_check=$(echo "$line" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/\r//') # Trimmed for comparison
    # Check if we hit the next level 2 heading, which signifies the end of this section
    #if [ -n "$trimmed_line_for_check" ]; then
      #if ! [[ "$trimmed_line_for_check" =~ ^## ]]; then
     #   echo "DEBUG (set_release_update_type.sh): Found valid content: '$line', stopping body extraction." >&2
     #   VALID_CONTENT="true"
     #   break # Stop collecting body content
      #else
      #fi
    #fi  
done <<< "$RELEASE_NOTES"

echo "HELLO"
if [ "$VALID_CONTENT" = "false" ]; then
  echo "Release Note doesnt contain valid information"
  exit 1
fi

# all good
echo "$UPDATE_TYPE" 
exit 0
        
