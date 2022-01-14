// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// NecoNFT is game props for NecoFishing game.
contract NecoNFT is ERC1155, ERC1155Burnable, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    // only creators can mint new NFT.
    mapping(address => bool) public creators;
    // uri mapping for tokenId
    mapping(uint => string) private uris;
    // TokenId array
    EnumerableSet.UintSet private tokenIds;
    // Some default NFTs need to be locked.
    EnumerableSet.UintSet private lockedTokenIds;
    mapping(address => bool) public transferWhitelist;

    constructor(string memory uri_) ERC1155(uri_) {}

    // before calling this function, we should upload metadata of this NFT to IPFS.
    // finally, minting a NFT by calling this function after getting the uri of ipfs.
    function create(
        uint tokenId,
        address to,
        string memory uri_,
        uint quantity,
        bytes memory data
    ) external onlyCreator {
        bytes memory uriBytes = bytes(uri_);
        require(uriBytes.length != 0, "uri can not be null");
        require(!tokenIds.contains(tokenId), "tokenId is existed!");
        uris[tokenId] = uri_;
        tokenIds.add(tokenId);
        _mint(to, tokenId, quantity, data);
    }

    function mint(uint tokenId, address to, uint quantity, bytes memory data) external onlyCreator {
        require(quantity > 0, "quantity cannot be 0!");
        require(tokenIds.contains(tokenId), "NFT has not been created!");
        _mint(to, tokenId, quantity, data);
    }

    function changeMetadataURI(string memory uri_) external onlyOwner {
        _setURI(uri_);
    }

    function changeUriById(uint id, string memory newUri) external onlyOwner {
        bytes memory uriBytes = bytes(newUri);
        require(uriBytes.length != 0, "uri can not be null");
        uris[id] = newUri;
    }

    function uri(uint id) public override view returns(string memory) {
        return uris[id];
    }

    function addCreator(address account) external onlyOwner {
        require(account != address(0), "creator can not be address 0");
        creators[account] = true;
    }

    function removeCreator(address account) external onlyOwner {
        creators[account] = false;
    }

    function addLockedNFT(uint id) external onlyOwner {
        lockedTokenIds.add(id);
    }

    function cancelLockingNFT(uint id) external onlyOwner {
        lockedTokenIds.remove(id);
    }

    function getTokenIdsLength() public view returns(uint) {
        return tokenIds.length();
    }

    function getTokenIdByIndex(uint index) public view returns(uint) {
        return tokenIds.at(index);
    }

    function getLockedTokenIdsLength() public view returns(uint) {
        return lockedTokenIds.length();
    }

    function getLockedTokenIdsByIndex(uint index) public view returns(uint) {
        return lockedTokenIds.at(index);
    }

    function addIntoTransferWhitelist(address account) external onlyOwner {
        require(account != address(0), "Account is 0");
        transferWhitelist[account] = true;
    }

    function removeFromTransferWhitelist(address account) external onlyOwner {
        require(account != address(0), "Account is 0");
        transferWhitelist[account] = false;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        require(!lockedTokenIds.contains(id) || transferWhitelist[from], "NFT is locked.");
        super.safeTransferFrom(from, to, id, amount, data);
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) public override {
        if (!transferWhitelist[from]) {
            for(uint i = 0; i < ids.length; i ++) {
                uint id = ids[i];
                if (lockedTokenIds.contains(id)) {
                    revert("Batch of NFT contains locked NFT!");
                }
            }
        }

        super.safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    modifier onlyCreator() {
        require(creators[msg.sender] == true, "restrict for creators!");
        _;
    }
}