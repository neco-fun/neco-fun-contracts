// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract NecoNFT is ERC1155, ERC1155Burnable, Ownable {
    using SafeMath for uint256;
    using Address for address;
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(address => bool) public creators;
    mapping(address => bool) public minters;
    // uri mapping for tokenId
    mapping(uint => string) private _uris;
    mapping(uint => uint) private _idToType1;
    mapping(uint => uint) private _idToType2;
    // TokenId array
    EnumerableSet.UintSet private _tokenIds;
    // Some default NFTs need to be locked.
    EnumerableSet.UintSet private _lockedTokenIds;
    mapping(uint => uint) public totalSupply;
    mapping(address => bool) public transferWhitelist;

    constructor(string memory uri_) ERC1155(uri_) {}

    event Create(uint indexed tokenId, address indexed to, string uri, uint quantity, uint type1, uint type2);
    event Mint(uint indexed tokenId, address indexed to, uint quantity);

    // before calling this function, we should upload metadata of this NFT to IPFS.
    // finally, minting a NFT by calling this function after getting the uri of ipfs.
    function create(
        uint tokenId,
        address to,
        string memory nftUrl,
        uint quantity,
        uint type1,
        uint type2,
        bytes memory data
    ) external onlyCreator {
        bytes memory uriBytes = bytes(nftUrl);
        require(uriBytes.length != 0, "uri can not be null");
        require(!_tokenIds.contains(tokenId), "tokenId is existed!");
        _uris[tokenId] = nftUrl;
        _tokenIds.add(tokenId);
        totalSupply[tokenId] = totalSupply[tokenId].add(quantity);
        _idToType1[tokenId] = type1;
        _idToType2[tokenId] = type2;
        _mint(to, tokenId, quantity, data);

        emit Create(tokenId, to, nftUrl, quantity, type1, type2);
    }

    function mint(uint tokenId, address to, uint quantity, bytes memory data) external onlyMinter {
        require(quantity > 0, "quantity cannot be 0!");
        require(_tokenIds.contains(tokenId), "NFT has not been created!");
        totalSupply[tokenId] = totalSupply[tokenId].add(quantity);
        _mint(to, tokenId, quantity, data);

        emit Mint(tokenId, to, quantity);
    }

    function changeMetadataURI(string memory newUri) external onlyOwner {
        _setURI(newUri);
    }

    function changeUri(uint id, string memory newUri) external onlyCreator {
        bytes memory uriBytes = bytes(newUri);
        require(uriBytes.length != 0, "uri can not be null");
        _uris[id] = newUri;
    }

    function uri(uint id) public override view returns(string memory) {
        return _uris[id];
    }

    function addCreator(address account) external onlyOwner {
        require(account != address(0), "creator can not be address 0");
        creators[account] = true;
    }

    function removeCreator(address account) external onlyOwner {
        creators[account] = false;
    }

    function addMinters(address account) external onlyOwner {
        require(account != address(0), "minter can not be address 0");
        minters[account] = true;
    }

    function removeMinter(address account) external onlyOwner {
        minters[account] = false;
    }

    function addLockedNFT(uint id) external onlyCreator {
        _lockedTokenIds.add(id);
    }

    function cancelLockedNFT(uint id) external onlyCreator {
        _lockedTokenIds.remove(id);
    }

    function getTokenIdsLength() public view returns(uint) {
        return _tokenIds.length();
    }

    function getTokenIdByIndex(uint index) public view returns(uint) {
        return _tokenIds.at(index);
    }

    function getLockedTokenIdsLength() public view returns(uint) {
        return _lockedTokenIds.length();
    }

    function getLockedTokenIdsByIndex(uint index) public view returns(uint) {
        return _lockedTokenIds.at(index);
    }

    function addIntoTransferWhitelist(address account) external onlyCreator {
        require(account != address(0), "Account is 0");
        transferWhitelist[account] = true;
    }

    function removeFromTransferWhitelist(address account) external onlyCreator {
        require(account != address(0), "Account is 0");
        transferWhitelist[account] = false;
    }

    function getNFTType1(uint id) public view returns(uint) {
        return _idToType1[id];
    }

    function changeNFTTYpe1(uint id, uint newType) external onlyCreator {
        _idToType1[id] = newType;
    }

    function getNFTType2(uint id) public view returns(uint) {
        return _idToType2[id];
    }

    function changeNFTType2(uint id, uint newType) external onlyCreator {
        _idToType2[id] = newType;
    }

    function safeTransferFrom(
        address from,
        address to,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public override {
        require(!_lockedTokenIds.contains(id) || transferWhitelist[from], "NFT is locked.");
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
                if (_lockedTokenIds.contains(id)) {
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

    modifier onlyMinter() {
        require(minters[msg.sender] == true, "restrict for minters!");
        _;
    }
}