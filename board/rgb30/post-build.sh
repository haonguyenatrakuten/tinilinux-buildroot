#!/bin/bash
# Check if user is root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." 
   exit 1
fi

# Partitions size, in MB
BOOT_SIZE=50
ROOTFS_SIZE=1024
# Sector size is 512 bytes & Default boot partition offset, in sectors (don't change this, it is required by u-boot)
SECTOR_SIZE=512
BOOT_PART_START=32768

DISK_START_PADDING=$(((${BOOT_PART_START} + 2048 - 1) / 2048))
DISK_GPT_PADDING=1
DISK_SIZE=$((${DISK_START_PADDING} + ${BOOT_SIZE} + ${ROOTFS_SIZE} + ${DISK_GPT_PADDING}))

BOOT_PART_END=$((${BOOT_PART_START} + (${BOOT_SIZE} * 1024 * 1024 / 512) - 1))
ROOTFS_PART_START=$((${BOOT_PART_END} + 1))
ROOTFS_PART_END=$((${ROOTFS_PART_START} + (${ROOTFS_SIZE} * 1024 * 1024 / 512) - 1))


cd ../../output/images

rm -f tinilinux-rgb30.img

# mkimage: Create an empty img file
echo "mkimage: Create an empty img file"
truncate -s ${DISK_SIZE}M tinilinux-rgb30.img

# mkimage: Make the disk MBR type (msdos)
echo "mkimage: Make the disk MBR type (msdos)"
parted tinilinux-rgb30.img mktable msdos

# mkimage: Write the u-boot to the img (offset 64 sectors = 32KiB)
echo "mkimage: Write the u-boot to the img (offset 64 sectors = 32KiB)"
dd if=u-boot-rockchip.bin of=tinilinux-rgb30.img bs=512 seek=64 conv=sync,notrunc

# mkimage: Making BOOT partitions
echo "mkimage: Making BOOT partitions"
parted -s tinilinux-rgb30.img -a min unit s mkpart primary fat32 ${BOOT_PART_START} ${BOOT_PART_END}

# mkimage: Making rootfs partitions
echo "mkimage: Making rootfs partitions"
parted -s tinilinux-rgb30.img -a min unit s mkpart primary ext4 ${ROOTFS_PART_START} ${ROOTFS_PART_END}

# mkimage: Set boot flag on the first partition
echo "mkimage: Set boot flag on the first partition"
parted -s tinilinux-rgb30.img set 1 boot on
sync


# Format partitions and mount
echo "mkimage: Format partitions and mount"
DEV_LOOP=$(losetup --show --find --partscan tinilinux-rgb30.img)
ls -la "${DEV_LOOP}"*
mkfs.fat -F32 -n BOOT ${DEV_LOOP}p1
mkfs.ext4 -O ^orphan_file -L rootfs ${DEV_LOOP}p2

mkdir -p /mnt/BOOT && mount -t vfat ${DEV_LOOP}p1 /mnt/BOOT
mkdir -p /mnt/rootfs && mount -t ext4 ${DEV_LOOP}p2 /mnt/rootfs

# Copy kernel, initrd, dtb to /mnt/BOOT
echo "mkimage: Copy kernel, initrd, dtb to /mnt/BOOT"
cp Image /mnt/BOOT/
cp ../../board/rgb30/uInitrd-6.12.43 /mnt/BOOT/uInitrd
cp ../../output/build/linux-6.12.43/arch/arm64/boot/dts/rockchip/rk3566-powkiddy-rgb30.dtb /mnt/BOOT/
cp -r ../../board/rgb30/BOOT/extlinux /mnt/BOOT/
# Extract buildroot (output/images/rootfs.tar) to /mnt/rootfs
echo "mkimage: Extract buildroot (output/images/rootfs.tar) to /mnt/rootfs"
tar -xf rootfs.tar -C /mnt/rootfs --no-same-owner
sync

# Unmount and Detach the img
echo "mkimage: Unmount and Detach the img"
umount /mnt/BOOT
umount /mnt/rootfs
rm -rf /mnt/BOOT /mnt/rootfs
losetup --detach-all

# mkimage: Verify
echo "mkimage: Verify"
parted tinilinux-rgb30.img unit MiB print

cd ../../board/rgb30

echo "Done."
