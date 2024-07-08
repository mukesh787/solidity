// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract TestContract1{
    address public owner=msg.sender;
    function setValue(address _owner)public{
        require(msg.sender==owner,"not owner");
        owner=_owner;
    }
}

contract proxy{
    event deploy(address);
    receive() external payable { }
    function Deploy(bytes memory _bytes)external payable returns(address addr){
        
        assembly{
           addr:= create(callvalue(),
            add(_bytes,0x20),
            mload(_bytes)
            )
        }

        require(addr!=address(0),"deploy failed");

        emit deploy(addr);
    }

    function execute(address _target,bytes memory _data)external payable{
        (bool success,)=_target.call{value:msg.value}(_data);
        require(success,"failed");

    }
}

contract Helper{
    function getByteCode()external pure returns(bytes memory){
        bytes memory bytecode=type(TestContract1).creationCode;
        return bytecode;
    }

    function getCalldata(address _owner)external pure returns(bytes memory){
        return abi.encodeWithSignature("setValue(address)", _owner);
    }
}

// 0x6435c3e70000000000000000000000005b38da6a701c568545dcfcb03fcb875f56beddc4