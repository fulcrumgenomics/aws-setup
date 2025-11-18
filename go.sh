#!/usr/bin/env sh

set -euo pipefail

#install git, htop
sudo yum update -y
sudo yum install git git-lfs htop -y 

# install pixi
wget -qO- https://pixi.sh/install.sh | sh

# install uv
wget -qO- https://astral.sh/uv/install.sh | sh

# tell the user to restart the shell
echo '======== You need to restart the shell in order for pixi to be available ========'
