#!/bin/bash

# Credit: @HoLengZai
# https://github.com/microsoft/azure-pipelines-agent/issues/3461#issuecomment-1250121953

sudo useradd -m AzDevOps
sudo usermod -a -G docker AzDevOps
sudo usermod -a -G adm AzDevOps
sudo usermod -a -G sudo AzDevOps

sudo chmod -R +r /home
setfacl -Rdm "u:AzDevOps:rwX" /home
setfacl -Rb /home/AzDevOps

sudo su -c "echo 'AzDevOps  ALL=(ALL) NOPASSWD:ALL' | sudo tee /etc/sudoers.d/01_AzDevOps && chmod 0440 /etc/sudoers.d/01_AzDevOps"

# Must be done after AzDevOps user creation
sudo su -c "find /opt/post-generation -mindepth 1 -maxdepth 1 -type f -name '*.sh' -exec bash {} \;"

pathFromEnv=$(cut -d= -f2 /etc/environment | tail -1)

mkdir /agent && chmod 775 /agent
echo "$pathFromEnv" > /agent/.path && chmod 444 /agent/.path
echo "PATH=$pathFromEnv" > /agent/.env && chmod 644 /agent/.env
chown -R AzDevOps:AzDevOps /agent

chattr +i /agent/.path
