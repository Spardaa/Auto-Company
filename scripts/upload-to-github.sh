#!/bin/bash
# Upload files to GitHub toolbox repo

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
    local content=$(base64 -w 0 "$file_path")

    # Get current SHA if file exists
    local sha=$(curl -s -H "Authorization: token $TOKEN" \
        "https://api.github.com/repos/$REPO/contents/$remote_path?ref=$BRANCH" | \
        jq -r '.sha // empty')

    local data="{\"message\":\"Update $remote_path\",\"content\":\"$content\",\"branch\":\"$BRANCH\""
    if [ -n "$sha" ]; then
        data="$data,\"sha\":\"$sha\""
    fi
    data="$data}"

    curl -s -X PUT \
        -H "Authorization: token $TOKEN" \
        -H "Accept: application/vnd.github.v3+json" \
        "https://api.github.com/repos/$REPO/contents/$remote_path" \
        -d "$data" > /dev/null

    echo "Uploaded: $remote_path"
}

# Upload index.html
upload_file "/mnt/c/Users/17503/Auto-Company/projects/toolbox-deploy/index.html" "index.html"

# Upload README
upload_file "/mnt/c/Users/17503/Auto-Company/projects/toolbox-deploy/README.md" "README.md"

# Upload all tools
for tool in /mnt/c/Users/17503/Auto-Company/projects/toolbox-deploy/tools/*.html; do
    filename=$(basename "$tool")
    upload_file "$tool" "tools/$filename"
done

echo "Done!"
