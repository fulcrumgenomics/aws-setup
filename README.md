# aws-setup
a repo to develop a simple script that installs everything we need on a new AWS instance

This repo is here so that when you fire up a new AWS instance you'll have an easy time installing all the _extra_ little bits that make the rest of your work easy.

For now this includes:

- git
- git-lfs
- htop
- pixi
- uv

# instructions:

log into your new aws and issue the following command:

```bash

curl --proto '=https' --tlsv1.2 -sSf https://github.com/fulcrumgenomics/ami-setup/go.sh | sh

```