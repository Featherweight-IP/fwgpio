MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
SYNTH_DIR := $(dir $(MKDV_MK))

MKDV_TOOL ?= openlane

MKDV_VL_SRCS += $(SYNTH_DIR)/fwgpio_32x4.v
TOP_MODULE = fwgpio_32x4

include $(SYNTH_DIR)/../common/defs_rules.mk

RULES := 1

include $(SYNTH_DIR)/../common/defs_rules.mk

