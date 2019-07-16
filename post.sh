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

# Install pikaur
if ! command_exists pikaur ; then
    git clone https://aur.archlinux.org/pikaur.git
    cd pikaur
    makepkg -fsri
	cd $WD
fi

# Install from AUR
pikaur --needed -S google-chrome spotify ttf-symbola nextcloud-client \
    rofi-greenclip
$SUDO ln -vfs /usr/bin/google-chrome-stable /usr/bin/netflix

# Set up git
mkdir -p ~/.git
ln -vfs ${WD}/global-gitignore ~/.git/global-gitignore
git config --global core.excludesfile '~/.git/global-gitignore'
git config --global user.email "brontitall@dds.nl"
git config --global user.name "Xeryus Stokkel"

# Set up git prompt
if [ ! -d ~/.bash-git-prompt ]; then
	git clone https://github.com/magicmonty/bash-git-prompt.git ~/.bash-git-prompt --depth=10
fi

# Set up i3
if [ ! -d ~/.i3 ]; then
	echo "Symlinking i3 config"
	mkdir -p ~/.i3
	ln -vfs ${WD}/i3/config ~/.i3/config
	ln -vfs ${WD}/i3/exit.sh ~/.i3/exit.sh
	ln -vfs ${WD}/i3/lock.sh ~/.i3/lock.sh
    ln -vfs ${WD}/i3/select_and_paste.sh ~/.i3/select_and_paste.sh
fi

$SUDO ln -vfs ${WD}/xsecurelock/saver_blank /usr/lib/xsecurelock/saver_blank
$SUDO ln -vfs ${WD}/xsecurelock/saver_mpv /usr/lib/xsecurelock/saver_mpv
$SUDO ln -vfs ${WD}/xsecurelock/getstreams.sh /usr/lib/xsecurelock/getstreams.sh
git submodule update --init --recursive
cd ${WD}/kittenstream
poetry install
cd ${WD}

mkdir -p ~/screenshots \
    ~/.config/rofi
ln -vfs ${WD}/alacritty.yml ~/.config/alacritty.yml
ln -vfs ${WD}/bashrc ~/.bashrc
ln -vfs ${WD}/redshift.conf ~/.config/redshift.conf
ln -vfs ${WD}/rofi/config.rasi ~/.config/rofi/config.rasi
ln -vfs ${WD}/rofi/solarized_alternate.rasi ~/.config/rofi/solarized_alterante.rasi
ln -vfs ${WD}/rofi/greenclip.cfg ~/.config/greenclip.cfg

# Enable greenclip
systemctl --user enable greenclip.service
systemctl --user start greenclip.service

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

# Enable pyenv so vim can be set up
export PYENV_ROOT="$HOME/.pyenv/"
if command_exists pyenv; then
	eval "$(pyenv init -)"
	eval "$(pyenv virtualenv-init -)"
fi

# Set up neovim
ln -vfs ${WD}/init.vim ~/.config/nvim/init.vim
if [ ! -f ~/.local/share/nvim/site/autoload/plug.vim ]; then
	curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
		https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# Python venvs for use with neovim
if [ ! -d $PYENV_ROOT/versions/2.7.15 ]; then
	$PYENV_ROOT/bin/pyenv install 2.7.15
fi
if [ ! -d $PYENV_ROOT/versions/3.7.0 ]; then
	$PYENV_ROOT/bin/pyenv install 3.7.0
fi
if [ ! -f $PYENV_ROOT/versions/neovim2 ]; then
	$PYENV_ROOT/bin/pyenv virtualenv 2.7.15 neovim2
fi
if [ ! -f $PYENV_ROOT/versions/neovim3 ]; then
	$PYENV_ROOT/bin/pyenv virtualenv 3.7.0 neovim3
fi
$PYENV_ROOT/versions/neovim2/bin/pip install --upgrade neovim jedi
$PYENV_ROOT/versions/neovim3/bin/pip install --upgrade neovim jedi

# neovim code completion for rust
rustup toolchain list | grep nightly
if [[ $? -eq 1 ]]; then
	rustup toolchain add nightly
fi
rustup component list | grep rust-src
if [[ $? -eq 1 ]]; then
	rustup component add rust-src
fi
if ! command_exists racer; then
	cargo +nightly install racer
fi

# neovim code code completion for typescript
$SUDO npm install -g typescript neovim

# Set up SpiderOak
if ! command_exists SpiderOakONE; then
	pikaur -S spideroak-one
fi
if [ ! -f ~/.config/SpiderOakONE/config.txt ]; then
	read -sp "SpiderOak password: " spideroakpass
	read -p "SpiderOak devicename: " spideroakname
	echo {\"username\":\"XeryusTC\",\"password\":\"${spideroakpass}\",\
		\"device_name\":\"${spideroakname}\",\"reinstall\":false} > /tmp/spideroak.json
	SpiderOakONE --setup=/tmp/spideroak.json
	rm /tmp/spideroak.json
fi
