// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Factory{
    event log(address addr);
    function deploy() external{
       
        bytes memory bytecode=hex"6960ff60005260206000f3600052600a6016f3";
        address addr;
        assembly{
            addr:=create(0,add(bytecode,0x02),0x13)
        }
        require(addr!=address(0),"deploy failed");
        emit log(addr);
    }
}

interface Icontract{
    function getValue()external view returns(uint);
}