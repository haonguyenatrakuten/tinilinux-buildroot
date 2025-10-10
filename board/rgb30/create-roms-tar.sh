#!/bin/bash

cd board/rgb30/ROMS
tar -Jcvf ../rootfs/root/roms.tar.xz .
cd ../../..