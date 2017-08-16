#!/bin/bash

echo
echo "Open Z-Wave Installer for Hassbian"
echo "Modified by Landrash for use with Hassbian."
echo "Remodified by unt1tled for use with Linear NGDZ00-4  (barrier_operator)."
echo "Remodified by Paul, for Hassbian .48.1 7/18/2017"
echo "Copyright(c) 2016 Dale Higgs <https://gitter.im/dale3h>"
echo

if [ "$(id -u)" != "0" ]; then
echo "This script must be run with sudo. Use \"sudo ${0} ${*}\"" 1>&2
exit 1
fi

echo "Running apt-get preparation"
apt-get update
apt-get upgrade -y
apt-get install -y make python3-dev libudev-dev python3-sphinx python3-setuptools libgnutlsxx28 libgnutls28-dev libssl-dev

echo "Changing to homeassistant user"
sudo -u homeassistant -H /bin/bash

echo "Activating virtualenv"
#################
#PE Update from
#source /srv/homeassistant/homeassistant_venv/bin/activate
# to
source /srv/homeassistant/bin/activate
#################

echo "Installing latest version of cython"
### Currently locked to this version since build fails for later versions.
pip3 install --upgrade cython==0.24.1


echo "Creating source directory"
mkdir -p /srv/homeassistant/src
chown -R homeassistant:homeassistant /srv/homeassistant/src

echo "Cloning python-openzwave"
cd /srv/homeassistant/src
git clone  https://github.com/OpenZWave/python-openzwave.git
chown homeassistant:homeassistant python-openzwave
cd python-openzwave

echo "Cloning openzwave"
git checkout python3
rm -rf openzwave
git clone git://github.com/OpenZWave/open-zwave.git openzwave
cd openzwave

echo "Changing to openzwave Dev branch to add barrier_operator support"
git checkout Dev
cd ..

echo "Building python-openzwave with barrier_operator support\nStage 1..."
make build
make install

# Remove the 1.4 non-dev branched compile and replace with the 1.5 dev branch compiled version
rm -Rf openzwave-git/open-zwave-master/
cp -R openzwave/ openzwave-git/
mv openzwave-git/openzwave/ openzwave-git/open-zwave-master/
echo "Building stage 2..."
make install

echo "Deactivating virtualenv"
deactivate
EOF

echo "Creating libmicrohttpd directory"
cd /srv/homeassistant/src
mkdir libmicrohttpd
chown homeassistant:homeassistant libmicrohttpd
cd /srv/homeassistant/src/libmicrohttpd

echo "Downloading libmicrohttpd-0.9.19"
wget ftp://ftp.gnu.org/gnu/libmicrohttpd/libmicrohttpd-0.9.19.tar.gz
chown homeassistant:homeassistant libmicrohttpd-0.9.19.tar.gz
tar zxvf libmicrohttpd-0.9.19.tar.gz
chown homeassistant:homeassistant libmicrohttpd-0.9.19

echo "Building libmicrohttpd-0.9.19"
cd libmicrohttpd-0.9.19
./configure
make
make install

echo "Cloning open-zwave-control-panel"
cd /srv/homeassistant/src
git clone https://github.com/OpenZWave/open-zwave-control-panel.git
chown -R homeassistant:homeassistant open-zwave-control-panel
cd open-zwave-control-panel

echo "Replacing open-zwave-control-panel source files with barrier_operator support"
#wget -O zwavelib.cpp https://raw.githubusercontent.com/legrego/open-zwave-control-panel/0925251a566a36543e0c6b5cb0b2c1498bddfa68/zwavelib.cpp


echo "Building open-zwave-control-panel"
rm Makefile
wget https://raw.githubusercontent.com/home-assistant/fabric-home-assistant/master/Makefile
chown homeassistant:homeassistant Makefile
make

echo "Linking ozwcp config directory"
ln -sd /srv/homeassistant/lib/python3.*/site-packages/libopenzwave-0.*-linux*.egg/config
chown -R homeassistant:homeassistant /srv/homeassistant/src

echo "Linking Home Assistant OpenZWave config directory"
cd /home/homeassistant/.homeassistant
sudo -u homeassistant ln -sd /srv/homeassistant/lib/python3.*/site-packages/libopenzwave-*-linux*.egg/config
chown -R homeassistant:homeassistant /home/homeassistant/.homeassistant

echo
echo "Installation done!"
echo
echo "If you have issues with this script, please contact @Landrash on gitter.im"
echo "Original script by @dale3h on gitter.im"
echo
