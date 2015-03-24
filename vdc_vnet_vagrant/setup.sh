#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

rpm -Uvh http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.5/kmod-openvswitch-2.3.0-1.el6.x86_64.rpm
rpm -Uvh http://dlc.openvnet.axsh.jp/packages/rhel/openvswitch/6.5/openvswitch-2.3.0-1.x86_64.rpm

# install source code
mkdir -p /opt/axsh; cd /opt/axsh
yes | git clone git@github.com:axsh/wakame-vdc.git
yes | git clone git@github.com:axsh/openvnet.git

# install config files
cp -r wakame-vdc/contrib/etc/* /etc/
cp -r openvnet/deployment/conf_files/etc/* /etc/
cp wakame-vdc/dcmgr/config/*.sample /etc/wakame-vdc/
cp openvnet/*.repo /etc/yum.repos.d/

# ruby settings
git clone https://github.com/sstephenson/rbenv.git ~/.rbenv
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
git clone https://github.com/sstephenson/ruby-build.git ~/.rbenv/plugins/ruby-build

yum -y install wakame-vdc-ruby openvnet-ruby

ln -s /opt/axsh/wakame-vdc/ruby ~/.rbenv/versions/vdc-ruby
ln -s /opt/axsh/openvnet/ruby ~/.rbenv/versions/vnet-ruby

echo "vdc-ruby" > /opt/axsh/wakame-vdc/.ruby-version
echo "vnet-ruby" > /opt/axsh/openvnet/.ruby-version

rbenv rehash

# rename them
for before in `ls /etc/wakame-vdc/*.example`; do
  after=`echo ${before} | sed -e "s/\.example//"`
  mv ${before} ${after}
done

# bundle install
(cd wakame-vdc/dcmgr; bundle install --path vendor/bundler)
(cd openvnet/vnet;    bundle install --path vendor/bundler)

if [ ! -e /var/log/wakame-vdc ]; then
  mkdir -p /var/log/wakame-vdc
fi

/vdc_vnet_tools/setup_vdc_db
/vdc_vnet_tools/setup_vnet_db
