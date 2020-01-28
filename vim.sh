# Remove previous installations
sudo apt-get remove vim vim-runtime vim-tiny vim-common

# Install dependencies
sudo apt-get install libncurses5-dev python-dev liblua5.3-dev lua5.3 python3-dev

# Fix liblua paths
# You have to compile luajit for yourself.
sudo ln -s /usr/include/lua5.3 /usr/include/lua
sudo ln -s /usr/lib/x86_64-linux-gnu/liblua5.3.so /usr/local/lib/liblua.so

# Clone vim sources
cd ~
git clone https://github.com/vim/vim.git

cd vim

./configure \
	--with-features=huge \
        --disable-selinux \
	--enable-luainterp \
	--enable-python3interp=dynamic \
	--with-python3-config-dir=/usr/lib/python3.6/config-3.6m-x86_64-linux-gnu \
	--enable-cscope \
	--disable-netbeans \
	--enable-terminal \
	--disable-xsmp \
	--enable-fontset \
	--enable-multibyte \
	--enable-fail-if-missing \
	--prefix=/usr/local

make VIMRUNTIMEDIR=/usr/local/share/vim/vim81

sudo apt-get install checkinstall
sudo checkinstall
