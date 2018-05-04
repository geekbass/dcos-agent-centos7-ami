#!/bin/bash
set -e

# Install epel-release for later
sudo yum install -y epel-release wget curl

# Setup Python
curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
sudo python get-pip.py
sudo rm -rf get-pip.py
sudo pip install virtualenv

# Install jq becasue it is awesome! Yay!
sudo wget https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -O /usr/bin/jq
sudo chmod 0775 /usr/bin/jq

# Install Ansible for Ansible Provisioner
sudo yum install -y ansible 

#reboot
#sudo reboot
