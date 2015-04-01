#!/bin/bash
#
# requires:
#  bash
#
set -e
set -o pipefail
set -x

whoami

function yum() {
  $(type -P yum) --disablerepo=updates "${@}"
}

# Add installation packages ...
addpkgs="
 gcc
 gcc-c++
 make
 git
 vim
 lxc
 lxc-templates
 tmux
 mysql-server
 libpcap-devel
 mysql-devel
 redis
 rabbitmq-server
 zeromq3-devel
 patch
 jemalloc
 splite-devel
"

if [[ -n "$(echo ${addpkgs})" ]]; then
  yum install -y ${addpkgs}
fi
