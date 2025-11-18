#!/usr/bin/env sh

set -euo pipefail

#install git, htop
sudo yum update -y
sudo yum install git git-lfs htop -y 

echo "Cloning repo..."
git clone https://github.com/fulcrumgenomics/aws-setup.git --single-branch

echo "Installing pixi..."
wget -qO- https://pixi.sh/install.sh | sh

if [ ! -f "~/.pixi/config.toml" ]; then
	echo "copying default pixi.toml to ~/.pixi/ "
	cp aws-setup/resources/pixi.default.toml  ~/.pixi/config.toml
else
	echo "~/.pixi/config.toml already exists. NOT overwriting."
fi 

. ~/.bashrc

# check that the default configuration is correct
pixi config ls

echo "Installing uv..."
wget -qO- https://astral.sh/uv/install.sh | sh

