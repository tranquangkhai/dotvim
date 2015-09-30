#!/bin/bash

# Clone my dotvim
DOTVIM=~/.vim

if [ ! -d $DOTVIM ]; then
    cd ~/
    git clone https://github.com/tranquangkhai/dotvim.git ~/.vim
    echo "doesn't exist .vim. Git Clone .vim"
fi

# Check if git directory is changed
cd $DOTVIM

if ! git diff-index --quiet HEAD; then
    echo ".vim was changed. Commit your changed"
    exit 2
fi

# remove all old Vim Scripts
BUNDLE=~/.vim/bundle

if [ -d $BUNDLE ]; then
    rm -rf $BUNDLE
fi

mkdir -p $BUNDLE

# Clone NeoBundle
git clone https://github.com/Shougo/neobundle.vim ${BUNDLE}/neobundle.vim

# Create symbolic link for .vimrc
if [ -f ~/.vimrc ]; then
    rm ~/.vimrc
fi

ln -s ~/.vim/vimrc ~/.vimrc

# Install all Vim Scripts
vim -c 'NeoBundleInstall'
vim -c 'qa' #exit vim

