// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
import "./IERC20.sol";

contract ERC20 is IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    uint256 public override totalSupply;
    mapping(address => uint256) public override balanceOf;
    mapping(address => mapping(address => uint256)) public override allowance;
    string public name;
    string public symbol;
    uint8 public decimals;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }
    function transfer(address recipient, uint256 amount)
    external
    returns (bool){
        balanceOf[msg.sender]-=amount;
        balanceOf[recipient]+=amount;
        emit Transfer(msg.sender,recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external returns (bool){
        allowance[msg.sender][spender]=amount;
        emit Approval(msg.sender, spender, amount);
        return true;  
    }

    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool){
            allowance[sender][msg.sender]-=amount;
            balanceOf[sender]-=amount;
            balanceOf[recipient]+=amount;
            emit Transfer(sender, recipient, amount);
            return true;
        }

    function mint(address _to,uint amount) external {
        balanceOf[_to]+=amount;
        totalSupply+=amount;
        emit Transfer(address(0),_to,amount);
    }

    function burn(address _from,uint amount) external{
        balanceOf[_from]-=amount;
        totalSupply-=amount;
        emit Transfer(_from,address(0),amount);
    }
}
