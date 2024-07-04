//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

contract IterableMapping{
    mapping(address=>uint)public balance;
    mapping(address=>bool)public inserted;
    address[] public keys;

    function set(address _keys,uint val)external{
        balance[_keys]=val;
        if(!inserted[_keys]){
            inserted[_keys]=true;
            keys.push(_keys);
        }
    }

    // examples

    function getsize() external view returns(uint){
        return keys.length;
    }
}