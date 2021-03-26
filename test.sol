pragma solidity ^0.8.1;

/// @title ERC-721 Non-Fungible Token Standard
/// @dev See https://eips.ethereum.org/EIPS/eip-721
///  Note: the ERC-165 identifier for this interface is 0x80ac58cd.
interface ERC721 /* is ERC165 */ {
    /// @dev This emits when ownership of any NFT changes by any mechanism.
    ///  This event emits when NFTs are created (`from` == 0) and destroyed
    ///  (`to` == 0). Exception: during contract creation, any number of NFTs
    ///  may be created and assigned without emitting Transfer. At the time of
    ///  any transfer, the approved address for that NFT (if any) is reset to none.
    event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);

    /// @dev This emits when the approved address for an NFT is changed or
    ///  reaffirmed. The zero address indicates there is no approved address.
    ///  When a Transfer event emits, this also indicates that the approved
    ///  address for that NFT (if any) is reset to none.
    event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);

    /// @dev This emits when an operator is enabled or disabled for an owner.
    ///  The operator can manage all NFTs of the owner.
    event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);

    /// @notice Count all NFTs assigned to an owner
    /// @dev NFTs assigned to the zero address are considered invalid, and this
    ///  function throws for queries about the zero address.
    /// @param _owner An address for whom to query the balance
    /// @return The number of NFTs owned by `_owner`, possibly zero
    function balanceOf(address _owner) external view returns (uint256);

    /// @notice Find the owner of an NFT
    /// @dev NFTs assigned to zero address are considered invalid, and queries
    ///  about them do throw.
    /// @param _tokenId The identifier for an NFT
    /// @return The address of the owner of the NFT
    function ownerOf(uint256 _tokenId) external view returns (address);

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT. When transfer is complete, this function
    ///  checks if `_to` is a smart contract (code size > 0). If so, it calls
    ///  `onERC721Received` on `_to` and throws if the return value is not
    ///  `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    /// @param data Additional data with no specified format, sent in call to `_to`
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) external payable;

    /// @notice Transfers the ownership of an NFT from one address to another address
    /// @dev This works identically to the other function with an extra data parameter,
    ///  except this function just sets data to "".
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Transfer ownership of an NFT -- THE CALLER IS RESPONSIBLE
    ///  TO CONFIRM THAT `_to` IS CAPABLE OF RECEIVING NFTS OR ELSE
    ///  THEY MAY BE PERMANENTLY LOST
    /// @dev Throws unless `msg.sender` is the current owner, an authorized
    ///  operator, or the approved address for this NFT. Throws if `_from` is
    ///  not the current owner. Throws if `_to` is the zero address. Throws if
    ///  `_tokenId` is not a valid NFT.
    /// @param _from The current owner of the NFT
    /// @param _to The new owner
    /// @param _tokenId The NFT to transfer
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;

    /// @notice Change or reaffirm the approved address for an NFT
    /// @dev The zero address indicates there is no approved address.
    ///  Throws unless `msg.sender` is the current NFT owner, or an authorized
    ///  operator of the current owner.
    /// @param _approved The new approved NFT controller
    /// @param _tokenId The NFT to approve
    function approve(address _approved, uint256 _tokenId) external payable;

    /// @notice Enable or disable approval for a third party ("operator") to manage
    ///  all of `msg.sender`'s assets
    /// @dev Emits the ApprovalForAll event. The contract MUST allow
    ///  multiple operators per owner.
    /// @param _operator Address to add to the set of authorized operators
    /// @param _approved True if the operator is approved, false to revoke approval
    function setApprovalForAll(address _operator, bool _approved) external;

    /// @notice Get the approved address for a single NFT
    /// @dev Throws if `_tokenId` is not a valid NFT.
    /// @param _tokenId The NFT to find the approved address for
    /// @return The approved address for this NFT, or the zero address if there is none
    function getApproved(uint256 _tokenId) external view returns (address);

    /// @notice Query if an address is an authorized operator for another address
    /// @param _owner The address that owns the NFTs
    /// @param _operator The address that acts on behalf of the owner
    /// @return True if `_operator` is an approved operator for `_owner`, false otherwise
    function isApprovedForAll(address _owner, address _operator) external view returns (bool);
}

interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

contract WTF is ERC721 {

    mapping(address => uint256) private balances;
    mapping(address => address[]) private operators;
    mapping(uint256 => address) private approved;
    mapping(uint256 => address) private owners;
    mapping(uint256 => bool) private received;
    mapping(uint256 => uint256) private lon;
    mapping(uint256 => uint256) private lat;
    mapping(uint256 => uint256) private radius;
    uint256[] private all_tokens;
    

    function transferFrom(address _from, address _to, uint256 _tokenId) override external payable {
        require(owners[_tokenId] == msg.sender || approved[_tokenId] == msg.sender || this.isApprovedForAll(owners[_tokenId], msg.sender), "Must be called from an owner");
        require(_from == owners[_tokenId], "Is not transferred from the owner");
        require(_to != address(0), "_to is zero");
        
        owners[_tokenId] = _to;
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId) override external payable {
        return this.safeTransferFrom(_from, _to, _tokenId, "");
    }
    
    function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes calldata data) override external payable {
        return this.transferFrom(_from, _to, _tokenId);

    }
    
     function balanceOf(address _owner) override external view returns (uint256) {
        return balances[_owner];
    }
    
    function ownerOf(uint256 _tokenId) override external view returns (address) {
        return owners[_tokenId];
    }
    
    
    
    function approve(address _approved, uint256 _tokenId) override external payable {
        require(owners[_tokenId] == msg.sender || this.isApprovedForAll(owners[_tokenId], msg.sender), "Must be called from an owner");
        approved[_tokenId] = _approved;
    }
    
    function setApprovalForAll(address _operator, bool _approved) override external {
        if (_approved && !this.isApprovedForAll(msg.sender, _operator)) {
            operators[msg.sender].push(_operator);
        } else if (!_approved && this.isApprovedForAll(msg.sender, _operator)) {
            int256 idx = -1;
            for (uint256 i = 0; i < operators[msg.sender].length; i++) {
                if (operators[msg.sender][i] == _operator) {
                    idx = int256(i);
                    break;
                }
            }
            if (idx >= 0) {
                uint256 uidx = uint256(idx);
                operators[msg.sender][uidx] = operators[msg.sender][operators[msg.sender].length - 1];
                operators[msg.sender].pop();
            }
        }
    }
    
   
    

    

    function getApproved(uint256 _tokenId) override external view returns (address) {
        return approved[_tokenId];
    }
    
    function isApprovedForAll(address _owner, address _operator) override external view returns (bool) {
        for (uint256 i = 0; i < operators[_owner].length; i++) {
            if (operators[_owner][i] == _operator) {
                return true;
            }
        }
        return false;
    }
    


    
    function claimLand (uint256 _lon, uint256 _lat, uint256 _radius, uint256 _tokenId) external payable {
        require(!received[_tokenId], "This land is already owned");
        
        for (uint256 i = 0; i < all_tokens.length; i++) {
            uint256 id = all_tokens[i];
            uint256 distance = this.sqrt((_lon - lon[id]) * (_lon - lon[id]) + (_lat - lat[id]) * (_lat - lat[id]));
            require(_radius + radius[id] < distance, "Lands are overlapped!");
        }
        
        owners[_tokenId] = msg.sender;
        received[_tokenId] = true;
        lon[_tokenId] = _lon;
        lat[_tokenId] = _lat;
        radius[_tokenId] = _radius;
        all_tokens.push(_tokenId);
    }
    function sqrt(uint y) external returns (uint z) {
    if (y > 3) {
        z = y;
        uint x = y / 2 + 1;
        while (x < z) {
            z = x;
            x = (y / x + x) / 2;
        }
    } else if (y != 0) {
        z = 1;
    }
}

}
