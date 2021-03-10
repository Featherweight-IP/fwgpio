'''
Created on Mar 9, 2021

@author: mballance
'''

import cocotb
import pybfms
from fwgpio_tests.bfm_mgr import BfmMgr

@cocotb.test()
async def entry(dut):
    
    await pybfms.init()
    
    print("Hello")
    bfms = BfmMgr()

    # Configure the    
    await bfms.config_pin_gpio_oe(0, 1)
    await bfms.config_pin_gpio_oe(1, 1)
    await bfms.config_pin_gpio_oe(2, 1)
    await bfms.config_pin_gpio_oe(3, 1)
    
    await bfms.config_pin_gpio_ov(0, 1)
    await bfms.config_pin_gpio_ov(1, 0)
    await bfms.config_pin_gpio_ov(2, 1)
    await bfms.config_pin_gpio_ov(3, 0)
    
    # Configure pin0 to take bank0
    await bfms.config_pin_bank(0, 0)
    bfms.bank_bfms[0].set_gpio_out_bit(0, 1)
    await bfms.bank_bfms[0].propagate()
    bfms.bank_bfms[0].set_gpio_out_bit(0, 0)
    await bfms.bank_bfms[0].propagate()
    bfms.bank_bfms[0].set_gpio_out_bit(0, 1)
    await bfms.bank_bfms[0].propagate()
    bfms.bank_bfms[0].set_gpio_out_bit(0, 0)
    await bfms.bank_bfms[0].propagate()
    bfms.bank_bfms[0].set_gpio_out_bit(0, 1)
    await bfms.bank_bfms[0].propagate()
    bfms.bank_bfms[0].set_gpio_out_bit(0, 0)
    await bfms.bank_bfms[0].propagate()
    
    
    
#    for bfm in pybfms.get_bfms():
#        print("BFM: " + bfm.bfm_info.inst_name)
    
    