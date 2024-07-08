// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
contract MinimalProxy{
    function clone(address target)external returns(address result){
        bytes20 targetBytes=bytes20(target);
        assembly{
            let clone:=mload(0x40)
            mstore(clone,0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            mstore(add(clone,0x14),targetBytes)
            mstore(add(clone,0x28),0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
            result:=create(0,clone,0x37)
        }
    }
}

// 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000
// is part of the standard EIP-1167 minimal proxy contract. This pattern is widely recognized
//  and used in the Ethereum ecosystem for creating minimal proxy contracts that delegate calls to a predefined implementation contract.

