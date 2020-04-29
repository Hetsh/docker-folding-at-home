#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Debian Stable
IMG_CHANNEL="stable"
update_image "library/debian" "Debian" "false" "$IMG_CHANNEL-\d+-slim"

# Folding@Home has folders for major versions, requiring two stage version scrape
FAH_VERSION_REGEX="(\d+\.)+\d+"
BASE_URL="https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit"
MAJOR_FAH_VERSION=$(curl -L -s "$BASE_URL" | grep -P -o "v$FAH_VERSION_REGEX" | sort --version-sort | tail -n 1)

# Folding@Home client
CURRENT_FAH_VERSION="${_CURRENT_VERSION%-*}"
NEW_FAH_VERSION=$(curl -L -s "$BASE_URL/$MAJOR_FAH_VERSION" | grep -P -o "$FAH_VERSION_REGEX" | sort --version-sort | tail -n 1)
if [ "$CURRENT_FAH_VERSION" != "$NEW_FAH_VERSION" ]; then
	prepare_update "" "Folding@Home" "$CURRENT_FAH_VERSION" "$NEW_FAH_VERSION"
	update_version "$NEW_FAH_VERSION"

	# Since the Folding@Home client is not a regular package, the version number needs
	# to be replaced with the url to download the binary
	_UPDATES[-3]="ARCHIVE_URL"
	_UPDATES[-2]="\".*\""
	_UPDATES[-1]="\"$BASE_URL/$MAJOR_FAH_VERSION/fahclient_$NEW_FAH_VERSION-64bit-release.tar.bz2\""
fi

# Packages
PKG_URL="https://packages.debian.org/$IMG_CHANNEL/amd64"
update_pkg "bzip2" "BZip2" "false" "$PKG_URL" "(\d+\.)+\d+-(\d+\.)+\d+~deb\d+u\d+"
update_pkg "ca-certificates" "CA-Certificates" "false" "$PKG_URL" "\d{8}"

if ! updates_available; then
	echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi