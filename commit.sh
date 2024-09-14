#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'

# Helper functions
print_message() { echo -e "\n${1}${2}${NO_COLOR}\n"; }
error_message() { print_message "${RED}" "Error: $1"; }
success_message() { print_message "${GREEN}" "$1"; }

generate_commit_message() {
  local changes
  changes=$(git diff --cached --shortstat 2>/dev/null)

  if [ -z "$changes" ]; then
    error_message "No changes detected. Please stage your changes before running this script."
    exit 1
  fi

  # Extract the type of changes
  local added=$(echo "$changes" | grep -oP '\d+ file\(s\) changed')
  local insertions=$(echo "$changes" | grep -oP '\d+ insertion\(s\)')
  local deletions=$(echo "$changes" | grep -oP '\d+ deletion\(s\)')

  # Create a basic commit message
  local commit_message="Auto-generated commit message: "

  if [ -n "$added" ]; then
    commit_message+="Updated files: $(echo "$changes" | grep -oP '\d+ file\(s\) changed'). "
  fi
  if [ -n "$insertions" ]; then
    commit_message+="Added $insertions. "
  fi
  if [ -n "$deletions" ]; then
    commit_message+="Removed $deletions. "
  fi

  # Provide a summary of the changes
  commit_message+="Summary: $(echo "$changes" | grep -oP '(?<=\d+ file\(s\) changed, )[^,]+')"

  echo "$commit_message"
}

# Check if there are any changes to commit
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Staging all changes..."
  git add . || {
    error_message "Failed to stage changes."
    exit 1
  }

  echo "Staged changes detected. Generating commit message..."
  commit_message=$(generate_commit_message)
  
  echo "Generated Commit Message:"
  echo "$commit_message"
  echo
  read -p "Do you want to use this message? (y/n): " choice

  if [ "$choice" == "y" ]; then
    git commit -m "$commit_message" || {
      error_message "Failed to commit changes."
      exit 1
    }
    success_message "Commit successful!"

    # Push to the current branch
    current_branch=$(git rev-parse --abbrev-ref HEAD)
    echo "Pushing to branch '$current_branch'..."
    git push origin "$current_branch" || {
      error_message "Failed to push to branch '$current_branch'."
      exit 1
    }
    success_message "Push successful!"
  else
    error_message "Commit aborted. Please commit manually."
    exit 1
  fi
else
  error_message "No changes detected. Please make changes before running this script."
  exit 1
fi
