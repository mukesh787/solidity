// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract Implementation {
    uint256 public value;

    event ValueSet(uint256 _value);

    function setValue(uint256 _value) public payable {
        value = _value;
        emit ValueSet(_value);
    }
}

// contract PseudoMinimalProxy {
//     address public masterCopy;

//     constructor(address _masterCopy) {
//         masterCopy = _masterCopy;
//     }

//     event ForwardedCall(bool success, bytes data, bytes error);

//     function forward() external payable returns (bytes memory) {
//         (bool success, bytes memory data) = masterCopy.delegatecall(abi.encodeWithSignature("setValue(uint256)",89));
//         if (!success) {
//             emit ForwardedCall(success, data, data);
//         }
//         require(success, "delegatecall failed");
//         emit ForwardedCall(success, data, "");
//         return data;
//     }
// }
// this commented code is like the original  pattern known as the "minimal proxy contract" or "EIP-1167 clone contract"