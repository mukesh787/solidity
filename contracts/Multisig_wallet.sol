//SPDX-License-Identifier:GPL-3.0
pragma solidity >=0.7.0 <=0.9.0;

contract wallet{
    event Deposit(address indexed sender,uint value,uint balance);
    event Submitted(address indexed owner,uint txnid,address indexed to, uint value);
    event Approved(address indexed owner, uint txnid);
    event Revoked(address indexed owner, uint txnid);
    event Executed(address indexed owner, uint txnid);
    uint public required;
    struct Transaction{
        address payable to;
        uint value;
        uint numberConfirmed;
        bool executed;
    }
    Transaction[] public transactions;
    address[] public owners;
    mapping(address=>bool)public isOwner;
    constructor(address[] memory _owners, uint  _required) {
        require(_owners.length>0,"owners should not be zero");
        require(_required>0 && _required<=_owners.length,"Invalid Transaction");
        for(uint i=0;i<_owners.length;i++){
            address owner=_owners[i];
            require(owner!=address(0),"invalid owner");
            require(!isOwner[owner],"unique owner required");
            isOwner[owner]=true;
            owners.push(owner);

        }
        required=_required;
    }
   
    modifier onlyOwners(){
        require(isOwner[msg.sender],"invalid owner");
        _;
    }

    modifier txnExists(uint txnid){
        require(txnid<=transactions.length,"invalid");
        _;
    }

    modifier notExecuted(uint txnid){
        require(!transactions[txnid].executed,"already executed");
        _;
    }
    mapping(uint=>mapping(address=>bool))public isConfirmed;
    modifier notApproved(uint txnid){
        require(!isConfirmed[txnid][msg.sender],"already approved");
        _;
    }

    receive() external payable { }

    function submit(address payable _to,uint amount)public  onlyOwners{
        uint txnid=transactions.length;
        transactions.push(Transaction({
            to:_to,
            value:amount,
            numberConfirmed:0,
            executed:false
        }));
        emit Submitted(msg.sender, txnid, _to, amount);
    }

    function approve(uint _txnid)public onlyOwners 
    txnExists(_txnid)
    notExecuted(_txnid)
    notApproved(_txnid){
        Transaction storage transaction=transactions[_txnid];
        transaction.numberConfirmed++;
        isConfirmed[_txnid][msg.sender]=true;

        emit Approved(msg.sender, _txnid);
    }

    function executed(uint _txnid)public onlyOwners
    txnExists(_txnid) 
    notExecuted(_txnid) {
        Transaction storage transaction=transactions[_txnid];
        require(transaction.numberConfirmed>=required,"not enough confirmations");
        transaction.executed=true;

        (bool success,)=transaction.to.call{value:transaction.value}("");
        require(success,"not executed");
        emit Executed(msg.sender, _txnid);
    }

    function revoke(uint _txnid) public onlyOwners txnExists(_txnid) notApproved(_txnid){
        Transaction storage transaction=transactions[_txnid];
        require(isConfirmed[_txnid][msg.sender],"not confirmed");
        transaction.numberConfirmed--;
        isConfirmed[_txnid][msg.sender]=false;
    }
}