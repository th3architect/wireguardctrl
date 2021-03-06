#!/usr/bin/env bash
set -e
set -x

# !! This script is meant for use in CI build use only !!

BINDIR=/home/build/go/bin

KERNEL=$(uname -s)
if [ "${KERNEL}" == "Linux" ]; then
    # Set up the WireGuard kernel module on Linux.
    sudo apt-get -y install software-properties-common
    sudo add-apt-repository -y ppa:wireguard/wireguard
    sudo apt-get --allow-unauthenticated -y update
    sudo apt-get --allow-unauthenticated -y install linux-headers-$(uname -r) wireguard-dkms wireguard-tools

    # Configure a WireGuard interface.
    sudo ip link add wg0 type wireguard
    sudo ip link set up wg0
fi

# Set up wireguard-go on all OSes.
git clone git://git.zx2c4.com/wireguard-go
cd wireguard-go

if [ "${KERNEL}" == "Linux" ]; then
    # Bypass Linux compilation restriction.
    make
else
    # Build directly to avoid Makefile.
    go build -o wireguard-go
fi

mkdir -p ${BINDIR}
sudo mv ./wireguard-go ${BINDIR}/wireguard-go
cd ..
sudo rm -rf ./wireguard-go
