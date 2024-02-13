#!/bin/sh -eux

echo "Adding  Desktop to Mini --Be Patient -- it can be loooong"    
apt-get update
apt-get -y install ubuntu-desktop        
systemctl set-default graphical.target	

