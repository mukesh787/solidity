// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

interface IERC165{
    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool);
}

interface IERC721 is IERC165 {
    function balanceOf(address owner) external view returns (uint256 balance);
    function ownerOf(uint256 tokenId) external view returns (address owner);
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external;
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;
    function transferFrom(address from, address to, uint256 tokenId) external;
    function approve(address to, uint256 tokenId) external;
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator);
    function setApprovalForAll(address operator, bool _approved) external;
    function isApprovedForAll(address owner, address operator)
        external
        view
        returns (bool);
}

interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721 is IERC721{
    event Transfer(address sender, address to, uint Id);
    event Approve(address owner,address spender,uint Id);
    event ApprovalForAll(
    address indexed owner, address indexed operator, bool approved
    );

    mapping(uint=>address)internal _ownerOf;
    mapping(address=>uint)internal _balanceOf;
    mapping(uint=>address)internal _approvals;
    mapping(address=>mapping(address=>bool))public isApprovedForAll;
    function supportsInterface(bytes4 interfaceId)
        external
        pure
        returns (bool){
        return interfaceId== type(IERC721).interfaceId
            || interfaceId == type(IERC165).interfaceId;
        }
    function balanceOf(address owner) external view returns (uint256 balance){
        balance=_balanceOf[owner];
        return balance;
    }
    function ownerOf(uint256 tokenId) external view returns (address owner){
        owner=_ownerOf[tokenId];
        return owner;
    }
    function approve(address to, uint256 tokenId) external{
        address owner=_ownerOf[tokenId];
        require(msg.sender==owner|| isApprovedForAll[owner][msg.sender],"not approved");
        _approvals[tokenId]=to;
        emit Approve(owner, to, tokenId);

    }
    function getApproved(uint256 tokenId)
        external
        view
        returns (address operator){
            require(_ownerOf[tokenId]!=address(0),"token does not exist");
            return _approvals[tokenId];
        }
    function setApprovalForAll(address operator, bool _approved) external{
        isApprovedForAll[msg.sender][operator]=true;
        emit ApprovalForAll(msg.sender, operator, _approved);
    }
    function _isApprovedOrOwner(address owner, address spender, uint256 id)
        internal
        view
        returns (bool){
            return (spender==owner || isApprovedForAll[owner][spender] || spender==_approvals[id]);
        }
    function transferFrom(address from, address to, uint256 tokenId) public{
        require(from==_ownerOf[tokenId],"not owner");
        require(to!=address(0),"to is not a zero address");
        require(isApprovedForAll[from][msg.sender],"not authorized");

        _balanceOf[from]--;
        _balanceOf[to]++;
        _ownerOf[tokenId]=to;

        delete _approvals[tokenId];
        emit Transfer(from, to, tokenId);
    }
    function safeTransferFrom(address from, address to, uint256 tokenId)
        external{
            transferFrom(from,to,tokenId);
            require(
                to.code.length==0 ||
                IERC721Receiver(to).onERC721Received(msg.sender,from,tokenId,"")==IERC721Receiver.onERC721Received.selector,
                "unsafe recipient"
            );
        }
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external{
        transferFrom(from,to,tokenId);
            require(
                to.code.length==0 ||
                IERC721Receiver(to).onERC721Received(msg.sender,from,tokenId,data)==IERC721Receiver.onERC721Received.selector,
                "unsafe recipient"
            );
    }
    function _mint(address to, uint256 id) internal {
        require(to != address(0), "mint to zero address");
        require(_ownerOf[id] == address(0), "already minted");

        _balanceOf[to]++;
        _ownerOf[id] = to;

        emit Transfer(address(0), to, id);
    }

    function _burn(uint256 id) internal {
        address owner = _ownerOf[id];
        require(owner != address(0), "not minted");

        _balanceOf[owner] -= 1;

        delete _ownerOf[id];
        delete _approvals[id];

        emit Transfer(owner, address(0), id);
    }
}

contract MyNFT is ERC721 {
    function mint(address to, uint256 id) external {
        _mint(to, id);
    }

    function burn(uint256 id) external {
        require(msg.sender == _ownerOf[id], "not owner");
        _burn(id);
    }
}
