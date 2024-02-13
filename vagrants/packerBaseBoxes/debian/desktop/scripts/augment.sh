#!/bin/sh -eux

echo "Adding  Desktop to Mini --Be Patient -- tasksel is silent and install can be loooong"    
apt-get update
apt-get -y install --reinstall debconf
apt-get -y install task-gnome-desktop
apt-get -y install task-laptop
systemctl set-default graphical.target	

