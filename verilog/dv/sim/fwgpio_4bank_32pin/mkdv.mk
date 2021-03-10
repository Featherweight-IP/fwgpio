MKDV_MK := $(abspath $(lastword $(MAKEFILE_LIST)))
TEST_DIR := $(dir $(MKDV_MK))
MKDV_TOOL ?= icarus

TOP_MODULE=fwgpio_4bank_32pin_tb

MKDV_VL_SRCS += $(wildcard $(TEST_DIR)/*.sv)
MKDV_PLUGINS += cocotb pybfms
PYBFMS_MODULES += rv_bfms gpio_bfms

MKDV_COCOTB_MODULE ?= fwgpio_tests.smoke
VLSIM_CLKSPEC += clock=10ns
VLSIM_OPTIONS += -Wno-fatal

include $(TEST_DIR)/../../common/defs_rules.mk

RULES := 1

include $(TEST_DIR)/../../common/defs_rules.mk
