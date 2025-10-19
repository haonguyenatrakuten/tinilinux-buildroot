[![Build](https://github.com/haoict/tinilinux-buildroot/actions/workflows/build.yaml/badge.svg?branch=master)](https://github.com/haoict/tinilinux-buildroot/actions/workflows/build.yaml)

# Tinilinux
## Build

To build and use the buildroot stuff, do the following:
```bash
# Install required packages
sudo apt install build-essential libncurses-dev parted dosfstools swig
# Build
export BOARD=<boardname> # e.g. rgb30, h700
make O=output.${BOARD} ${BOARD}_defconfig
make O=output.${BOARD} menuconfig # you can also cd to output.${BOARD} and run make menuconfig
make O=output.${BOARD} -j$(nproc) # you can also cd to output.${BOARD} and run make -j$(nproc)
# The kernel, bootloader, root filesystem, etc. are in output images directory
# Make flashable img file
sudo board/${BOARD}/mk-flashable-img.sh
```

## Install
## Flash to sdcard
There are many tools to flash img file to SDCard such as Rufus, Balena Etcher.
But if you prefer command line:
```bash
# Check your sdcard device
lsblk
# Assuming your sdcard is /dev/sdb, unmount all mounted partitions of your sdcard if automount 
sudo umount /dev/sdb*
# Flash the img to sdcard
sudo dd if=output.${BOARD}/images/tinilinux-${BOARD}.img of=/dev/sdb bs=4M conv=fsync status=progress
sudo sync
sudo udisksctl power-off -b /dev/sdb
```

## Update rootfs only without reflashing sdcard
```bash
sudo mount -t ext4 /dev/sdb /mnt/rootfs
sudo rm -rf /mnt/rootfs/*
sudo tar -xvf output.${BOARD}/images/rootfs.tar -C /mnt/rootfs && sync 
sudo umount /dev/sdb
sudo eject /dev/sdb
```

## Notes
### Clean target build without rebuild all binaries and libraries
Ref: https://stackoverflow.com/questions/47320800/how-to-clean-only-target-in-buildroot

```bash
cd output.${BOARD}
rm -rf target && find  -name ".stamp_target_installed" -delete && rm -f build/host-gcc-final-*/.stamp_host_installed
```

### Unpack/Repack uInitrd
Unpack
```bash
mkdir uInitrd-root
cd uInitrd-root
zcat ../uInitrd | cpio -id
```

Repack
```bash
find . | cpio -o -H newc | gzip > ../uInitrd-modified
```

### Run Docker
```bash
wget https://download.docker.com/linux/static/stable/aarch64/docker-26.1.4.tgz
tar -xzvf docker-26.1.4.tgz
cp docker/* /usr/bin/
dockerd &
docker run -p 8080:80 -d --name hello --rm nginxdemos/hello
docker ps -a
curl localhost:8080
```