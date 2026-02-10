#!/usr/bin/env bash
#
# Usage:
#
#   # defaults to /mnt/data with ext4
#   sudo -E bash setup_volume.sh
#
#   # custom mount point and filesystem
#   sudo -E bash setup_volume.sh /mnt/mydata xfs
#
# The -E preserves $USER so ownership gets set to your user rather than root.

set -euo pipefail

MOUNT_POINT="${1:-/mnt/data}"
FS_TYPE="${2:-ext4}"

# Find NVMe or xvd devices with no partitions and no mountpoint
DEVICE=$(lsblk -dpno NAME,TYPE,MOUNTPOINT | awk '$2 == "disk" && $3 == "" {print $1}' | grep -E 'nvme|xvd' | head -1)

if [[ -z "$DEVICE" ]]; then
  echo "ERROR: No unmounted disk device found." >&2
  exit 1
fi

echo "Found unmounted device: $DEVICE"

# Check if it already has a filesystem
FS_CHECK=$(sudo file -s "$DEVICE")
if echo "$FS_CHECK" | grep -q ': data'; then
  echo "Creating $FS_TYPE filesystem on $DEVICE..."
  sudo mkfs -t "$FS_TYPE" "$DEVICE"
else
  echo "Device already has a filesystem: $FS_CHECK"
fi

# Create mount point
sudo mkdir -p "$MOUNT_POINT"

# Mount it
sudo mount "$DEVICE" "$MOUNT_POINT"

# Get UUID and add to fstab if not already there
UUID=$(sudo blkid -s UUID -o value "$DEVICE")

if grep -q "$UUID" /etc/fstab; then
  echo "UUID $UUID already in /etc/fstab, skipping."
else
  sudo cp /etc/fstab /etc/fstab.bak
  echo "UUID=$UUID  $MOUNT_POINT  $FS_TYPE  defaults,nofail  0  2" | sudo tee -a /etc/fstab
fi

# Set ownership to the calling user
sudo chown "$USER:$USER" "$MOUNT_POINT"

echo "Done. $DEVICE mounted at $MOUNT_POINT (UUID=$UUID)"
df -h "$MOUNT_POINT"