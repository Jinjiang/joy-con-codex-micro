#!/bin/bash

set -euo pipefail

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <version>" >&2
    exit 64
fi

release_version="$1"
if [[ ! "$release_version" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Version must use X.Y.Z format, for example 0.1.0." >&2
    exit 64
fi

script_directory="$(cd "$(dirname "$0")" && pwd)"
repository_root="$(cd "$script_directory/.." && pwd)"
application_name="JoyConCodexController"
resource_bundle_name="joy-con-codex-controller_JoyConCodexController.bundle"
architecture="$(uname -m)"
artifact_directory="$repository_root/dist"
application_bundle="$artifact_directory/$application_name.app"
archive_name="$application_name-$release_version-macOS-$architecture.zip"
archive_path="$artifact_directory/$archive_name"

cd "$repository_root"

swift build --configuration release --product "$application_name"
binary_directory="$(swift build --configuration release --show-bin-path)"
executable_path="$binary_directory/$application_name"
resource_bundle_path="$binary_directory/$resource_bundle_name"

if [[ ! -x "$executable_path" ]]; then
    echo "Missing release executable: $executable_path" >&2
    exit 1
fi

if [[ ! -d "$resource_bundle_path" ]]; then
    echo "Missing SwiftPM resource bundle: $resource_bundle_path" >&2
    exit 1
fi

mkdir -p "$artifact_directory"
if [[ -e "$application_bundle" ]]; then
    rm -rf "$application_bundle"
fi
rm -f "$archive_path" "$archive_path.sha256"

mkdir -p \
    "$application_bundle/Contents/MacOS" \
    "$application_bundle/Contents/Resources"

install -m 755 \
    "$executable_path" \
    "$application_bundle/Contents/MacOS/$application_name"
install -m 644 \
    "$repository_root/Packaging/Info.plist" \
    "$application_bundle/Contents/Info.plist"
install -m 644 \
    "$repository_root/Assets/AppIcon/AppIcon.icns" \
    "$application_bundle/Contents/Resources/AppIcon.icns"
ditto \
    "$resource_bundle_path" \
    "$application_bundle/Contents/Resources/$resource_bundle_name"

/usr/libexec/PlistBuddy \
    -c "Set :CFBundleShortVersionString $release_version" \
    "$application_bundle/Contents/Info.plist"

# GitHub-hosted runners do not have this project's Developer ID certificate.
# Ad-hoc signing keeps the bundle internally consistent; notarized distribution
# can replace this step after signing credentials are configured in GitHub.
codesign --force --sign - --timestamp=none "$application_bundle"
codesign --verify --deep --strict --verbose=2 "$application_bundle"

ditto -c -k --sequesterRsrc --keepParent \
    "$application_bundle" \
    "$archive_path"

(
    cd "$artifact_directory"
    shasum -a 256 "$archive_name" > "$archive_name.sha256"
)

echo "Created $archive_path"
echo "Created $archive_path.sha256"
