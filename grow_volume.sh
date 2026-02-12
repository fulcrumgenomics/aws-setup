#!/bin/bash

# EBS Volume Expansion Script
# Automatically detects and expands the root partition

set -e

echo "=== EBS Volume Expansion Script ==="
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

# Display current disk usage
echo "Current disk usage:"
df -h /
echo ""

# Find the root device
ROOT_PARTITION=$(findmnt -n -o SOURCE /)
echo "Root partition: $ROOT_PARTITION"

# Extract device name (remove partition number)
if [[ $ROOT_PARTITION == *"nvme"* ]]; then
    # NVMe device (e.g., /dev/nvme0n1p1 -> /dev/nvme0n1)
    DEVICE=$(echo $ROOT_PARTITION | sed 's/p[0-9]*$//')
    PART_NUM=$(echo $ROOT_PARTITION | grep -oP 'p\K[0-9]+$')
else
    # Standard device (e.g., /dev/xvda1 -> /dev/xvda)
    DEVICE=$(echo $ROOT_PARTITION | sed 's/[0-9]*$//')
    PART_NUM=$(echo $ROOT_PARTITION | grep -oP '[0-9]+$')
fi

echo "Device: $DEVICE"
echo "Partition number: $PART_NUM"

# Detect filesystem type
FS_TYPE=$(lsblk -no FSTYPE "$ROOT_PARTITION")
echo "Filesystem type: $FS_TYPE"
echo ""

# Check if expansion is needed
DEVICE_SIZE=$(lsblk -bdno SIZE "$DEVICE" | head -1)
PART_SIZE=$(lsblk -bdno SIZE "$ROOT_PARTITION" | head -1)

if [ "$DEVICE_SIZE" -le $((PART_SIZE + 1048576)) ]; then
    echo "No expansion needed - partition already uses full device size."
    exit 0
fi

echo "Expansion possible: Device is larger than partition"
echo ""

read -p "Proceed with expansion? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "Step 1: Expanding partition..."
growpart "$DEVICE" "$PART_NUM"

echo ""
echo "Step 2: Resizing filesystem..."

if [ "$FS_TYPE" == "xfs" ]; then
    xfs_growfs -d /
elif [ "$FS_TYPE" == "ext4" ] || [ "$FS_TYPE" == "ext3" ] || [ "$FS_TYPE" == "ext2" ]; then
    resize2fs "$ROOT_PARTITION"
else
    echo "Error: Unsupported filesystem type: $FS_TYPE"
    exit 1
fi

echo ""
echo "=== Expansion Complete ==="
echo ""
echo "New disk usage:"
df -h /
echo ""
echo "Done!"
