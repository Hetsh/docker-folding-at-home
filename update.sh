#!/usr/bin/env bash


# Abort on any error
set -e -u

# Simpler git usage, relative file paths
CWD=$(dirname "$0")
cd "$CWD"

# Load helpful functions
source libs/common.sh
source libs/docker.sh

update_custom() {
	local ID="$1"
	local NAME="$2"
	local MAJOR_VERSION_REGEX="\d+\.\d+"
	local VERSION_REGEX="$MAJOR_VERSION_REGEX\.\d+"
	local MIRROR="https://download.foldingathome.org/releases/public/release/fahclient/debian-stable-64bit"

	local CURRENT_URL=$(cat Dockerfile | grep --only-matching --perl-regexp "(?<=$ID=\").*(?=\")")
	local CURRENT_VERSION=$(echo "$CURRENT_URL" | grep --only-matching --perl-regexp "$VERSION_REGEX")
	if [ -z "$CURRENT_URL" ] || [ -z "$CURRENT_VERSION" ]; then
		echo -e "\e[31mFailed to scrape current $NAME version from Dockerfile!\e[0m"
		return
	fi
	local MAJOR_VERSION=$(curl --silent --location "$MIRROR" | grep --only-matching --perl-regexp "$MAJOR_VERSION_REGEX" | uniq | sort --version-sort | tail -n 1)
	local PARTIAL_URL="$MIRROR/v$MAJOR_VERSION"
	local VERSION=$(curl --silent --location "$PARTIAL_URL" | grep --only-matching --perl-regexp "$VERSION_REGEX" | uniq | sort --version-sort | tail -n 1)
	if [ -z "$MAJOR_VERSION" ] || [ -z "$VERSION" ]; then
		echo -e "\e[31mFailed to scrape $NAME version!\e[0m"
		return
	fi
	local NEW_URL="$PARTIAL_URL/fahclient_${VERSION}_amd64.deb"

	if [ "$CURRENT_URL" != "$NEW_URL" ]; then
		prepare_update "$ID" "$NAME" "$CURRENT_VERSION" "$NEW_VERSION" "$CURRENT_URL" "$NEW_URL"
		update_version "$NEW_VERSION"
	fi
}

# Check dependencies
assert_dependency "jq"
assert_dependency "curl"

# Debian Stable
IMG_CHANNEL="stable"
update_image "amd64/debian" "Debian" "false" "$IMG_CHANNEL-\d+-slim"

# Folding@Home
update_custom "PKG_URL" "Folding@Home"

# Packages
PKG_URL="https://packages.debian.org/$IMG_CHANNEL/amd64"
update_pkg "bzip2" "BZip2" "false" "$PKG_URL" "(\d+\.)+\d+-\d+"
update_pkg "ca-certificates" "CA-Certificates" "false" "$PKG_URL" "\d{8}"

if ! updates_available; then
	#echo "No updates available."
	exit 0
fi

# Perform modifications
if [ "${1-}" = "--noconfirm" ] || confirm_action "Save changes?"; then
	save_changes

	if [ "${1-}" = "--noconfirm" ] || confirm_action "Commit changes?"; then
		commit_changes
	fi
fi
