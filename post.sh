#!/usr/bin/sh

if ! [ $(id -u) = 0 ]; then
	SUDO=sudo
else
	SUDO=
fi
HOSTNAME=$(cat /etc/hostname)
WD=$(pwd)

command_exists () {
	command -v $1 2>/dev/null ;
}

echo "Updating software"
$SUDO pacman -Syuq --noconfirm
echo "Installing new software"
$SUDO pacman -Sq --needed --noconfirm - < softwarelist.txt

if ! command_exists qualia ; then
	$SUDO pip install mir.qualia
fi
# Set git qualia settings
if [[ $(git config --get filter.qualia.clean | head -c1 | wc -c) -eq 0 ]]; then
	echo "Setting up qualia for this repository"
	git config filter.qualia.clean qualia
	git config filter.qualia.smudge "qualia $HOSTNAME"
	rm .git/index
	git checkout HEAD -- "$(git rev-parse --show-toplevel)"
fi

# Install aurman
if ! command_exists aurman ; then
	git clone https://aur.archlinux.org/aurman.git aurman
	cd aurman
	makepkg -si
	cd $WD
fi

# Set up i3
if [ ! -d ~/.i3 ]; then
	echo "Symlinking i3 config"
	mkdir -p ~/.i3
	ln -fs ${WD}/i3/config ~/.i3/config
	ln -fs ${WD}/i3/exit.sh ~/.i3/exit.sh
	ln -fs ${WD}/i3/lock.sh ~/.i3/lock.sh
fi

ln -fs ${WD}/Xresources ~/.Xresources

# Set up lightdm
$SUDO ln -fs ${WD}/lightdm.conf /etc/lightdm/lightdm.conf
