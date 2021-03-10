
FWGPIO_VERILOG_RTLDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))


ifneq (1,$(RULES))

ifeq (,$(findstring $(FWGPIO_VERILOG_RTLDIR),$(MKDV_INCLUDED_DEFS)))
MKDV_INCLUDED_DEFS += $(FWGPIO_VERILOG_RTLDIR)

MKDV_VL_SRCS += $(wildcard $(FWGPIO_VERILOG_RTLDIR)/*.v)
MKDV_VL_INCDIRS += $(FWGPIO_VERILOG_RTLDIR)

include $(PACKAGES_DIR)/fwprotocol-defs/verilog/rtl/defs_rules.mk

endif


else # Rules

endif
