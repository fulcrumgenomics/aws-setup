# aws-setup
a repo to develop a simple script that installs everything we need on a new AWS instance

This repo is here so that when you fire up a new AWS instance you'll have an easy time installing all the _extra_ little bits that make the rest of your work easy.

This (currently) includes:
- git
- git-lfs
- htop
- pixi
- uv

# instructions:

log into your new aws and issue the following command:

```bash

wget -qO- https://raw.githubusercontent.com/fulcrumgenomics/aws-setup/refs/heads/main/go.sh | sh

```

After the installs, you need to restart your shell for everything to be available, so either call "bash"/"zsh" or disconnect and reconnect to the instance.

## Mounting an EBS volume

If your instance has an attached (but unmounted) EBS volume, use `setup_volume.sh` to format, mount, and persist it via `/etc/fstab`:

```bash
# defaults to /mnt/data with ext4
sudo -E bash setup_volume.sh

# custom mount point and filesystem
sudo -E bash setup_volume.sh /mnt/mydata xfs
```

The `-E` flag preserves `$USER` so ownership of the mount point gets set to your user rather than root.
