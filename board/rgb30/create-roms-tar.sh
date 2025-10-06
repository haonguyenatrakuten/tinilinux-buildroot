#!/bin/bash

cd board/rgb30/ROMS
tar -Jcvf ../rootfs/roms.tar.xz .
cd ../../..