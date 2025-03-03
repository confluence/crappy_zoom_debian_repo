#!/bin/bash

deb_name=zoom_amd64.deb
deb_url=https://zoom.us/client/latest/$deb_name
repo_path=/var/lib/zoomrepo
header_size=132

# Download truncated deb package to get metadata

cd /tmp

# First we find out the size of the control archive by downloading only the header
wget -q -O - $deb_url | head -c $header_size > header.deb
archive_size=`lesspipe header.deb | grep -oP '(?<=control archive=)\d+'`

# Then we find out the package version by downloading the header plus the control archive
combined_size=$(( archive_size + header_size ))
wget -q -O - $deb_url | head -c $combined_size > header_archive.deb
latest_version=`lesspipe header_archive.deb | grep -Po '(?<=Version: ).*'`

# Clean up temporary files
rm header.deb header_archive.deb

mkdir -p $repo_path
cd $repo_path

# Check if the latest .deb version is newer than what we already have
download=0
if [ ! -f Packages ]
then
    download=1
else
    current_version=`grep -Po '(?<=Version: ).*' Packages`
    dpkg --compare-versions $latest_version gt $current_version && download=1
fi

# Only download the full package if we actually need to
if [ "$download" -eq 1 ]
then
    wget -q -O $deb_name $deb_url
    apt-ftparchive packages . > Packages
    apt-ftparchive release . > Release
fi
