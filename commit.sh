#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NO_COLOR='\033[0m'


print_message() { echo -e "\n${1}${2}${NO_COLOR}\n"; }
error_message() { print_message "${RED}" "Error: $1"; }
success_message() { print_message "${GREEN}" "$1"; }

generate_commit_message() {
  local staged_changes
  staged_changes=$(git diff --cached --name-status)

  if [ -z "$staged_changes" ]; then
    error_message "No changes detected. Please stage your changes before running this script."
    exit 1
  fi

  local commit_message="### Auto-Generated Commit Message\n\n"
  local files_added=0
  local files_modified=0
  local files_deleted=0
  local summary=""

  while IFS=$'\t' read -r status file; do
    case "$status" in
      A) 
        files_added=$((files_added + 1))
        summary+="Added: $file\n"
        ;;
      M) 
        files_modified=$((files_modified + 1))
        summary+="Modified: $file\n"
        ;;
      D) 
        files_deleted=$((files_deleted + 1))
        summary+="Deleted: $file\n"
        ;;
    esac
  done <<< "$staged_changes"

  commit_message+="**Files Added**: $files_added\n"
  commit_message+="**Files Modified**: $files_modified\n"
  commit_message+="**Files Deleted**: $files_deleted\n\n"
  commit_message+="**Summary of Changes**:\n$summary"

  echo -e "$commit_message"
}

# check if there are any changes to commit
if ! git diff --quiet || ! git diff --cached --quiet; then
  echo "Staging all changes..."
  git add . || {
    error_message "Failed to stage changes."
    exit 1
  }

  echo "Staged changes detected. Generating commit message..."
  commit_message=$(generate_commit_message)
  
  echo "Generated Commit Message:"
  echo -e "$commit_message"
  echo
  read -p "Do you want to use this message? (y/n): " choice

  if [ "$choice" == "y" ]; then
    git commit -m "$commit_message" || {
      error_message "Failed to commit changes."
      exit 1
    }
    success_message "Commit successful!"


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
