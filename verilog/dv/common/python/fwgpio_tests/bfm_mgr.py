'''
Created on Mar 9, 2021

@author: mballance
'''
import pybfms
from gpio_bfms.GpioBfm import GpioBfm
from rv_bfms.rv_addr_line_en_initiator_bfm import RvAddrLineEnInitiatorBfm
from typing import List

class BfmMgr(object):
    
    def __init__(self):
        
        # Find the pinmux BFM first
        self.pinmux = pybfms.find_bfm(".*pinmux_bfm", GpioBfm)
        
        # Now, find the bank BFMS
        bank_bfms = pybfms.find_bfms(".*bank_bfm.*", GpioBfm)
        for i,b in enumerate(bank_bfms):
            lb = b.bfm_info.inst_name.rfind("[")
            rb = b.bfm_info.inst_name.rfind("]")
            idx = int(b.bfm_info.inst_name[lb+1:rb])
            bank_bfms[i] = (idx,b)
            print("Bank BFM: " + b.bfm_info.inst_name + " " + str(idx))
            
        bank_bfms.sort(key=lambda e : e[0])
        self.bank_bfms : List[GpioBfm] = list(map(lambda e : e[1], bank_bfms))
        
        print("bank_bfms: " + str(self.bank_bfms))
            
        # TODO: need to sort
        
        # Find the pin BFMs
        pin_bfms = pybfms.find_bfms(".*pin_bfm.*", GpioBfm)

        for i,b in enumerate(pin_bfms):
            lb = b.bfm_info.inst_name.rfind("[")
            rb = b.bfm_info.inst_name.rfind("]")
            idx = int(b.bfm_info.inst_name[lb+1:rb])
            pin_bfms[i] = (idx,b)
            
        pin_bfms.sort(key=lambda e : e[0])
        self.pin_bfms : List[GpioBfm] = list(map(lambda e : e[1], pin_bfms))
        
        self.reg_bfm : RvAddrLineEnInitiatorBfm = pybfms.find_bfm(".*reg_bfm", RvAddrLineEnInitiatorBfm)
        
    async def config_pin_gpio(self, pin):
        cfg = await self.reg_bfm.read(2*pin)
        cfg &= 0xFFFFFEFF
        await self.reg_bfm.write(2*pin, cfg)
    
    async def config_pin_bank(self, pin, sel):
        cfg = await self.reg_bfm.read(2*pin)
        cfg |= 0x0000000100 # Enable banksel mode
        cfg |= (sel & 0xFF) # Select the bank
        await self.reg_bfm.write(2*pin, cfg)

    async def config_pin_gpio_ov(self, pin, val):
        cfg = await self.reg_bfm.read(2*pin)
        cfg &= 0xFFFFFDFF     # Clear the out_v
        cfg |= (val & 1) << 9 # Set the value
        await self.reg_bfm.write(2*pin, cfg)
        
    async def config_pin_gpio_oe(self, pin, en):
        cfg = await self.reg_bfm.read(2*pin)
        cfg &= 0xFFFFFBFF     # Clear the out_e
        cfg |= (en & 1) << 10 # Set the value
        await self.reg_bfm.write(2*pin, cfg)

