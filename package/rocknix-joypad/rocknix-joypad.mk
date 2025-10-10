################################################################################
#
# rocknix-joypad
#
################################################################################

ROCKNIX_JOYPAD_VERSION = 43245fbce81f28f56e9174e5a8cd94c72c97b161
ROCKNIX_JOYPAD_SITE = https://github.com/ROCKNIX/rocknix-joypad
ROCKNIX_JOYPAD_SITE_METHOD = git
ROCKNIX_JOYPAD_LICENSE = GPL
ROCKNIX_JOYPAD_MODULE_MAKE_OPTS = DEVICE=RK3566

$(eval $(kernel-module))
$(eval $(generic-package))
