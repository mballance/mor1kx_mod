

ifneq (1,$(RULES))

TARGET=or1k-elf-
CC=$(TARGET)gcc
AS=$(TARGET)gcc
CXX=$(TARGET)g++
LD=$(TARGET)ld

else # Rules

endif


