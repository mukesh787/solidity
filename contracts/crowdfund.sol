// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;
interface IERC20 {
    function transfer(address, uint256) external returns (bool);
    function transferFrom(address, address, uint256) external returns (bool);
}

contract crowdFund{
    event Cancel(uint);
    event Pledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Unpledge(uint256 indexed id, address indexed caller, uint256 amount);
    event Claim(uint256 id);
    event Refund(uint256 id, address indexed caller, uint256 amount);
    struct Campaign{
        address creator;
        uint goal;
        uint pledged;
        uint32 startAt;
        uint32 endAt;
        bool claimed;
    }
    IERC20 public immutable token;
    uint public count;
    mapping(uint=>Campaign)public campaigns;
    mapping(uint=>mapping(address=>uint)) public pledgedAmount;

    constructor(address _token){
        token=IERC20(_token);
    }

    function launch(uint _goal,uint32 _startAt,uint32 _endAt)external{
        require(_startAt>=block.timestamp,"start at < now");
        require(_endAt>=_startAt,"end at < starting time");
        require(_endAt<=block.timestamp+90 days,"end at > max duration ");
        
        count++;
        campaigns[count]=Campaign({
            creator : msg.sender,
            goal : _goal,
            pledged : 0,
            startAt : _startAt,
            endAt : _endAt,
            claimed: false
        });

    }

    function cancel(uint _id)external{
        Campaign memory campaign=campaigns[_id];
        require(campaign.creator==msg.sender,"not creator");
        require(block.timestamp<campaign.startAt,"campaign started");

        delete campaigns[_id];
        emit Cancel(_id);
    }

    function pledge(uint256 _id, uint256 _amount) external{
        Campaign storage campaign=campaigns[_id];
        require(block.timestamp>=campaign.startAt,"campaign not started");
        require(block.timestamp <= campaign.endAt, "ended");
        
        campaign.pledged+=_amount;
        pledgedAmount[_id][msg.sender]+=_amount;
        token.transferFrom(msg.sender,address(this),_amount );

        emit Pledge(_id, msg.sender, _amount);
    }

    function unPledge(uint _id,uint _amount)external{
        Campaign storage campaign=campaigns[_id];
        // require(block.timestamp>=campaign.startAt,"campaign not started");
        require(block.timestamp <= campaign.endAt, "ended");

        campaign.pledged-=_amount;
        pledgedAmount[_id][msg.sender]-=_amount;
        token.transfer(msg.sender,_amount);
         emit Unpledge(_id, msg.sender, _amount);
    }

    function claim(uint _id)external{
        Campaign storage campaign=campaigns[_id];
        require(block.timestamp >campaign.endAt, "not ended");
        require(campaign.creator==msg.sender,"not owner");
        require(campaign.pledged>=campaign.goal,"not enough amount");
        require(!campaign.claimed,"already claimed");

        campaign.claimed=true;
        token.transfer(campaign.creator,campaign.pledged);
        emit Claim(_id);
    }

    function refund(uint _id)external{
        Campaign storage campaign=campaigns[_id];
        require(block.timestamp >campaign.endAt, "not ended");
        require(campaign.creator==msg.sender,"not owner");
        require(campaign.pledged<campaign.goal,"not enough amount");
        uint bal=pledgedAmount[_id][msg.sender];
        pledgedAmount[_id][msg.sender]=0;
        token.transfer(msg.sender,bal);
        emit Refund(_id, msg.sender, bal);
    }
    
}