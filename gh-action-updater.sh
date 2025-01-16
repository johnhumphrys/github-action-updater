#!/bin/bash

WORKFLOW_DIR=".github/workflows"
GITHUB_API_URL="https://api.github.com/repos"

get_latest_version() {
    local action_repo=$1
    curl -s "${GITHUB_API_URL}/${action_repo}/tags" | jq -r '.[0].name'
}

for workflow in "$WORKFLOW_DIR"/*.yml "$WORKFLOW_DIR"/*.yaml; do
    if [[ -f "$workflow" ]]; then
        echo "Processing: $workflow"

        # Extract all actions with versions in the workflow
        actions=$(grep -oE 'uses: [^@]+@[^ ]+' "$workflow" | sed 's/uses: //')

        for action in $actions; do
            repo=$(echo "$action" | cut -d'@' -f1)
            current_version=$(echo "$action" | cut -d'@' -f2)
            latest_version=$(get_latest_version "$repo")

            if [[ -n "$latest_version" && "$current_version" != "$latest_version" ]]; then
                echo "Updating $repo from $current_version to $latest_version"
            fi
        done
        echo "Done: $workflow"
    fi
done
