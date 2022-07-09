// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Holder.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "../../NFT/INecoNFT.sol";


contract NecoFishingItemStore is Ownable, ERC1155Holder {
    IERC20 public nfish;
    IERC20 public busd;
    INecoNFT public necoNFT;

    address public devAccount;
    address public operator;

    event DepositNFISHTokenSuccessfully(address indexed from, address indexed to, uint amount);
    event DepositBUSDTokenSuccessfully(address indexed from, address indexed to, uint amount);
    event DepositBatchNFTSuccessfully(address indexed from, address indexed to, uint256[] ids, uint256[] values);

    event WithdrawNFISHTokenSuccessfully(address indexed to, uint amount);
    event WithdrawBUSDTokenSuccessfully(address indexed to, uint amount);
    event WithdrawBatchNFTsSuccessfully(address indexed to, uint256[] ids, uint256[] values);

    constructor(INecoNFT _necoNFT, IERC20 _nfish, IERC20 _busd, address _devAccount, address _operator) {
        necoNFT = _necoNFT;
        nfish = _nfish;
        _busd = busd;
        devAccount = _devAccount;
        operator = _operator;
    }

    function depositNFISHToken(uint amount) external {
        nfish.transferFrom(msg.sender, address(this), amount);

        emit DepositNFISHTokenSuccessfully(msg.sender, address(this), amount);
    }

    function depositBUSDToken(uint amount) external {
        busd.transferFrom(msg.sender, address(this), amount);

        emit DepositBUSDTokenSuccessfully(msg.sender, address(this), amount);
    }

    function depositBatchNFTs(uint256[] calldata nftIds, uint256[] calldata amounts) external {
        necoNFT.burnBatch(msg.sender, nftIds, amounts);

        emit DepositBatchNFTSuccessfully(address(this), msg.sender, nftIds, amounts);
    }

    function withdrawNFISHToken(address to, uint amount) external onlyOperator {
        require(amount > 0, "incorrect amount");
        uint balance = nfish.balanceOf(address(this));
        require(amount <= balance, "Out of balance.");
        nfish.transfer(to, amount);

        emit WithdrawNFISHTokenSuccessfully(to, amount);
    }

    function withdrawBUSDToken(address to, uint amount) external onlyOperator {
        require(amount > 0, "incorrect amount");
        uint balance = nfish.balanceOf(address(this));
        require(amount <= balance, "Out of balance.");
        busd.transfer(to, amount);

        emit WithdrawBUSDTokenSuccessfully(to, amount);
    }

    function withdrawBatchNFTs(address to, uint256[] calldata nftIds, uint256[] calldata amounts) external onlyOperator {
        uint length = nftIds.length;
        for (uint i = 0; i < length; i++) {
            require(amounts[i] > 0, "amout cannot be 0");
            necoNFT.mint(nftIds[i], address(this), amounts[i], "Withdraw from Neco Fishing");
        }

        necoNFT.safeBatchTransferFrom(address(this), to, nftIds, amounts, "Withdraw from Neco Fishing");
        emit WithdrawBatchNFTsSuccessfully(to, nftIds, amounts);
    }

    modifier onlyOperator() {
        require(msg.sender == operator, "restrict for operator.");
        _;
    }

    function emergencyWithdrawNFISH() external onlyOwner {
        uint balance = nfish.balanceOf(address(this));
        nfish.transfer(owner(), balance);
    }

    function emergencyWithdrawBUSD() external onlyOwner {
        uint balance = busd.balanceOf(address(this));
        busd.transfer(owner(), balance);
    }
}