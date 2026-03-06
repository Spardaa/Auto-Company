#!/bin/bash

TOKEN="${GITHUB_TOKEN:-}"
REPO="Spardaa/toolbox"
BRANCH="main"

if [ -z "$TOKEN" ]; then
    echo "Error: GITHUB_TOKEN environment variable not set"
    exit 1
fi

upload_file() {
    local file_path="$1"
    local remote_path="$2"

    if [ ! -f "$file_path" ]; then
        echo "File not found: $file_path"
        return
    fi

    local content=$(base64 -w 0 "$file_path")

    # Check if file exists and local sha_response=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/contents/$remote_path?ref=$BRANCH")

    local sha=""
    if echo "$sha_response" | grep -q '"sha"'; then
        sha=$(echo "$sha_response" | grep -o '"sha": "[^"]*"' | sed 's/"sha": "\([^"]*\)", "\1"/')
        echo "File exists, updating..."
    fi

    local data="{\"message\":\"Add/update $remote_path\",\"content\":\"$content\",\"branch\":\"$BRANCH"
    if [ -n "$sha" ]; then
        data="$data,\"sha\":\"$sha\"}"
    data="$data}"

    local response=$(curl -s -X PUT \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/contents/$remote_path" \
        -d "$data")

    if echo "$response" | grep -q '"sha"'; then
        echo "Success: Uploaded $remote_path"
    else
        echo "Failed: $remote_path"
        echo "$response"
    fi
}

# Upload robots.txt
upload_file "/mnt/c/Users/17503/Auto-Company/projects/toolbox-deploy/robots.txt" "robots.txt"

# Upload sitemap.xml
upload_file "/mnt/c/Users/17503/Auto-Company/projects/toolbox-deploy/sitemap.xml" "sitemap.xml"

echo "Done!"
