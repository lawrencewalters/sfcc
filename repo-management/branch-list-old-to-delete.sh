#!/bin/bash
# This script lists remote Git branches that are older than a specified number of years
# and fully merged into the default branch. It also generates commands to delete these branches.
# and outputs that into delete_commands.txt
# run it with `bash delete_commands.txt`

# Fetch all remote branches and their metadata
git fetch --all --prune

# Replace 'main' with your default branch name if it's different
DEFAULT_BRANCH=master

# Get the current timestamp for x years ago
OLD_DATE=$(date -d "3 years ago" +%s)

echo "Branches older than $(date -d @$OLD_DATE '+%Y-%m-%d') and fully merged into $DEFAULT_BRANCH:"

# Get the list of merged branches once and store it
MERGED_BRANCHES=$(git branch -r --merged origin/$DEFAULT_BRANCH | awk '{print $1}')

# Clear the delete commands files
> branch_delete_commands.txt
> branch_special_branches_review.txt

# List all remote branches that are fully merged into the default branch and older than x years
while IFS= read -r line; do
    # Parse the line into date, time, offset, branch, and commit message
    # Use tab as delimiter since commit messages might contain spaces
    IFS=$'\t' read -r datetime branch commit_msg <<< "$line"
    # Split datetime into components
    read -r date time offset <<< "$datetime"

    # Check if the branch is older
    if [[ $(date -d "$date $time $offset" +%s) -lt $OLD_DATE ]]; then
        # Check if the branch is fully merged
        echo "$date -- $branch"
        echo "  Last commit: $commit_msg"
        if echo "$MERGED_BRANCHES" | grep -q "^$branch$"; then
            echo "  merged"
            # Strip 'origin/' prefix for the delete command
            branch_name=${branch#origin/}

            # Check if this is a special branch that needs extra review
            if [[ $branch_name =~ ^(hotfix|develop|release) ]]; then
                echo "# SPECIAL BRANCH - REVIEW CAREFULLY: $branch_name" >> branch_special_branches_review.txt
                echo "# Last commit: $commit_msg" >> branch_special_branches_review.txt
                echo "# Date: $date" >> branch_special_branches_review.txt
                echo "git push origin --delete $branch_name" >> branch_special_branches_review.txt
                echo "" >> branch_special_branches_review.txt
                echo "  -> Added to branch_special_branches_review.txt for manual review"
            else
                echo "git push origin --delete $branch_name" >> branch_delete_commands.txt
            fi
        fi
    fi
done < <(git for-each-ref --sort=committerdate refs/remotes/ --format='%(committerdate:iso8601)	%(refname:short)	%(subject)')