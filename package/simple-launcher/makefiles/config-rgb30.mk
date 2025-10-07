# CROSS_COMPILE = /opt/toolchains/arm64/aarch64-linux-gnu-7.5.0-linaro/bin/aarch64-linux-gnu-
# SYSROOT = /opt/toolchains/arm64/sysroot

# CFLAGS += -I$(SYSROOT)/usr/include -DRGB30
# LDFLAGS += -L${SYSROOT}/usr/lib -lpthread -Wl,-rpath-link,$(SYSROOT)/usr/lib

CFLAGS += -DRGB30 -DDEBUG
