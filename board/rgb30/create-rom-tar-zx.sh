#!/bin/bash

cd board/rgb30/roms_tar_xz
tar -Jcvf ../rootfs_overlay_systemd/roms.tar.xz .
cd ../../..