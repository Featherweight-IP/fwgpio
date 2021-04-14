
FWGPIO_VERILOG_SYNTH_COMMONDIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
FWGPIO_DIR := $(abspath $(FWGPIO_VERILOG_SYNTH_COMMONDIR)/../../..)
PACKAGES_DIR := $(FWGPIO_DIR)/packages
DV_MK := $(shell PATH=$(PACKAGES_DIR)/python/bin:$(PATH) python3 -m mkdv mkfile)

ifneq (1,$(RULES))

include $(FWGPIO_DIR)/verilog/rtl/defs_rules.mk
# Must be included last
include $(DV_MK)
else # Rules

# Must be included first
include $(DV_MK)
include $(FWGPIO_DIR)/verilog/rtl/defs_rules.mk
endif
