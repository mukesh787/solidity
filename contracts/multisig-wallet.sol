//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;
contract multisig{
    uint private _transactionCount;
    address[] public owners;
    mapping(address=>bool) public isowner;
    uint public numConfirmationNeeded;
    struct Transaction{
        address payable to;
        uint256 value;
        bool executed;
        uint256 numConfirmations;
    }

    mapping(uint=>mapping(address=>bool)) public isConfirmed;
    Transaction[] public transactions;

    modifier onlyOwner(){
        require(isowner[msg.sender],"not an owner");
        _;
    }
    function submitTransaction(address payable to,uint amount) external onlyOwner returns(uint) {
        uint transactionId=_transactionCount+1;
        transactions[transactionId]=Transaction(to,amount,false,0);
        _transactionCount++;
        return transactionId;
    }

    function approve(uint id)public onlyOwner{
        require(!transactions[id].executed,"already executed");
        require(!isConfirmed[id][msg.sender],"alreadyConfirmed");
        isConfirmed[id][msg.sender]=true;
        transactions[id].numConfirmations++;

        if(transactions[id].numConfirmations>=numConfirmationNeeded){
            executeTransaction(id);
        }
    }

    function executeTransaction(uint id)public{
        require(transactions[id].numConfirmations>=numConfirmationNeeded,"not enough approval");
        Transaction storage transaction=transactions[id];
        transaction.executed=true;
        transaction.to.transfer(transaction.value);
    }
}