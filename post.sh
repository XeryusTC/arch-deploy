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
$SUDO sed -i 's/^#Color$/Color/' /etc/pacman.conf
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

# Install from AUR
aurman -S alacritty-scrollback-git google-chrome spotify ttf-symbola
$SUDO ln -vfs /usr/bin/google-chrome-stable /usr/bin/netflix

# Set up git
mkdir -p ~/.git
ln -vfs ${WD}/global-gitignore ~/.git/global-gitignore
git config --global core.excludesfile '~/.git/global-gitignore'
git config --global user.email "armadillo@onenetbeyond.org"
git config --global user.name "Xeryus Stokkel"

# Set up i3
if [ ! -d ~/.i3 ]; then
	echo "Symlinking i3 config"
	mkdir -p ~/.i3
	ln -vfs ${WD}/i3/config ~/.i3/config
	ln -vfs ${WD}/i3/exit.sh ~/.i3/exit.sh
	ln -vfs ${WD}/i3/lock.sh ~/.i3/lock.sh
fi

ln -vfs ${WD}/alacritty.yml ~/.config/alacritty.yml
ln -vfs ${WD}/bashrc ~/.bashrc
ln -vfs ${WD}/redshift.conf ~/.config/redshift.conf
mkdir -p ~/screenshots

# Set up lightdm
#$SUDO ln -vfs ${WD}/lightdm.conf /etc/lightdm/lightdm.conf

# Set up xorg
# BEGIN armadillo
#$SUDO ln -vfs ${WD}/armadillo-monitor.conf /etc/X11/xorg.conf.d/10-monitor.conf
# END armadillo

# Set up polybar
mkdir -p ~/.config/polybar
ln -vfs ${WD}/polybar/config ~/.config/polybar/config
ln -vfs ${WD}/polybar/launch.sh ~/.config/polybar/launch.sh
ln -vfs ${WD}/polybar/system-cpu-loadavg.sh \
	~/.config/polybar/system-cpu-loadavg.sh
chmod +x ~/.config/polybar/launch.sh

# Enable sound
amixer set Master unmute 100

# Set up pyenv
if ! command_exists pyenv; then
	git clone --depth=2 https://github.com/pyenv/pyenv.git ~/.pyenv
	git clone --depth=2 https://github.com/pyenv/pyenv-virtualenv.git \
		~/.pyenv/plugins/pyenv-virtualenv
fi

# Set up vim
ln -vfs ${WD}/vimrc ~/.vimrc
mkdir -p ~/.vim/autoload ~/.vim/bundle
if [ ! -f ~/.vim/autoload/pathogen.vim ]; then
	curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
fi
if [ ! -d ~/.vim/bundle/rust.vim ]; then
	git clone --depth=2 https://github.com/rust-lang/rust.vim.git \
		~/.vim/bundle/rust.vim
fi
if [ ! -d ~/.vim/bundle/typescript-vim ]; then
	git clone --depth=2 https://github.com/leafgarland/typescript-vim.git \
		~/.vim/bundle/typescript-vim
fi

# Set up SpiderOak
if ! command_exists SpiderOakONE; then
	aurman -S spideroak-one
fi
if [ ! -f ~/.config/SpiderOakONE/config.txt ]; then
	read -sp "SpiderOak password: " spideroakpass
	read -p "SpiderOak devicename: " spideroakname
	echo {\"username\":\"XeryusTC\",\"password\":\"${spideroakpass}\",\
		\"device_name\":\"${spideroakname}\",\"reinstall\":false} > /tmp/spideroak.json
	SpiderOakONE --setup=/tmp/spideroak.json
	rm /tmp/spideroak.json
fi
