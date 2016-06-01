
ifneq (1,$(RULES))

MOR1KX_MOD_FW_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

LIB_TARGETS += libcore.o
INCLUDES += -I$(MOR1KX_MOD_FW_DIR)/include -I$(MOR1KX_MOD_FW_DIR)/include/asm

CFLAGS += $(INCLUDES)
CXXFLAGS += $(INCLUDES)
ASFLAGS += $(INCLUDES)

MOR1KX_LIBCORE := libcore.o
MOR1KX_LIBCORE_SRC_S= \
  start.S   \
  ashldi3.S \
  ashrdi3.S \
  lshrdi3.S \
  muldi3.S 
  
MOR1KX_LIBCORE_SRC_C= \
  cache.c
  

else

$(MOR1KX_LIBCORE) : $(MOR1KX_LIBCORE_SRC_S:.S=.o) $(MOR1KX_LIBCORE_SRC_C:.c=.o)
	$(LD) -r -o $@ $^

%.o : $(MOR1KX_MOD_FW_DIR)/%.S
	$(Q)$(AS) $(ASFLAGS) -c -o $@ $^
	
%.o : $(MOR1KX_MOD_FW_DIR)/%.c
	$(Q)$(CC) $(CFLAGS) -c -o $@ $^

endif

