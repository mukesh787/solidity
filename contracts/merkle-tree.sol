// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

contract merkle{
    function verify(bytes[] memory proof, bytes32 root, bytes32 leaf, uint index)public pure returns(bool){
        bytes32 hash=leaf;
        for(uint i=0;i<proof.length;i++){
            if(index%2==0){
                hash=keccak256(abi.encode(proof[i],hash));
            }else{
                hash=keccak256(abi.encode(hash,proof[i]));
            }
            index/=2;
        }

        return hash==root;
    }
}