#
#	Simple Terminal config for RGB30 SDL12COMPAT
#		based on RG350 ver https://github.com/jamesofarrell/st-sdl
#

INCS += -DRGB30_SDL12COMPAT -DSDL12COMPAT

CFLAGS += -mtune=cortex-a55 -mcpu=cortex-a55
