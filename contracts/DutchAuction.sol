// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC721 {
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    function transferFrom(address, address, uint256) external;
}

contract dutchAuction{
    uint private constant Duration=7 days;
    IERC721 public immutable nft;
    uint public immutable nftId;

    uint public immutable startingPrice;
    uint public immutable discount;
    uint public immutable startAt;
    uint public immutable endAt;
    address payable public immutable seller;

    constructor(uint _startingprice,uint _discount,address _nft, uint _nftId){
        seller=payable(msg.sender);
        startingPrice=_startingprice;
        discount=_discount;
        startAt=block.timestamp;
        endAt=block.timestamp+Duration;

        require(_startingprice>=_discount*Duration,"starting price < discount");
        nft=IERC721(_nft);
        nftId=_nftId;
    }

    function getPrice()public view returns(uint){
        uint timeElapsed=block.timestamp-startAt;
        uint Discount=discount*timeElapsed;
        return startingPrice-Discount;
    }

    function buy()external payable{
        require(block.timestamp<endAt,"auction Ended");
        uint Price=getPrice();

        require(msg.value>=Price,"less eth");
        nft.transferFrom(seller, msg.sender, nftId);
        uint refund=msg.value-Price;
        if(refund>0){
        payable(msg.sender).transfer(refund);
        }

         (bool success,) = payable(seller).call{value: Price}("");
        if (!success) {
            revert("call{value} failed");
        }
    }

}