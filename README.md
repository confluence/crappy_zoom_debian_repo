# What is this?

A quick and dirty way to set up a local repository around the Zoom Debian package downloaded from the official site. This allows you to install and update Zoom using `apt` instead of downloading the package manually and installing it with `dpkg`.

This means that the first time you install it, all the dependencies will be handled automatically, and that whenever you update and upgrade with `apt` you will also get the updated package automatically if a newer version was downloaded into your local repository since the last time you installed it.

You still have to run the command to install the package yourself (like you do with most other packages).

# Requirements

This should work on any Debian-based distro where the official Zoom `.deb` package works.

The script which creates and updates the repository uses `wget` and `apt-ftparchive`, so you need to have these available. On Ubuntu `apt-ftparchive` is provided by the `apt-utils` package.

# Instructions

```bash
# Get this repository
git clone https://github.com/confluence/crappy_zoom_debian_repo.git
cd crappy_zoom_debian_repo

# Run the script once to create the repo for the first time
sudo ./updatezoomrepo.sh

# Make the script run daily
sudo cp updatezoomrepo.sh /etc/cron.daily/

# Add the local repo to your sources
sudo cp zoom.list /etc/apt/sources.list.d/

# Update to tell Apt abut your repo
sudo apt-get update

# Install or upgrade zoom
sudo apt-get install zoom
```

# Daily? I don't want to download a 200M file daily!

The script uses a horrible hack to determine whether the latest package on the server is newer than the package in the repo, without downloading the whole package. First it downloads only the header of the file (which is 132 bytes) and finds out the size of the control archive (the part of the file which stores the package metadata). Then it downloads the file only up to the end of that segment (about 30K at time of writing). Then it reads the package version from that metadata, and only if it's newer does it download the entire file and update the local repository.

# Apt is printing some lines about InRelease and Release.gpg when I update

This repository is the bare minimum that works. It isn't authenticated. Since it's a way for you to automate giving yourself a package that you downloaded yourself from the official Zoom website, this seems pretty safe. You could do some extra stuff to authenticate the repository, but then this would all be more complicated, and also it wouldn't be crappy.

# Zoom says there's an updated version now!

Run the script again as root, and you should be able to upgrade.

```bash
sudo /etc/cron.daily/updatezoomrepo.sh
sudo apt-get update
sudo apt-get install zoom
```

If you want, you can also copy or symlink the script into your path.

# Surely someone else has already done this!

Probably, but the similar solutions I found were either too complicated or too vague or downloaded the file every time, so here we are.

# Something is broken!

Please file an issue, and I'll see what I can do.
