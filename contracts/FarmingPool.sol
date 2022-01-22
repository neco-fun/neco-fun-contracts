// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

// Farming Pool
contract FarmingPool is Ownable {
    using SafeMath for uint;
    using SafeERC20 for IERC20;
    using Address for address;
    using EnumerableSet for EnumerableSet.AddressSet;

    IERC20 public necoToken;
    IERC20 public lpToken;

    //LP token balances
    mapping(address => uint) private _lpBalances;
    EnumerableSet.AddressSet private _addressSet;
    uint private _lpTotalSupply;

    // next time of decreasing
    uint public halvingTime = 0;
    uint public lastUpdateTime = 0;
    // distribution of per second
    uint public rewardRate = 0;
    uint public rewardPerLPToken = 0;
    mapping(address => uint) private rewards;
    mapping(address => uint) private userRewardPerTokenPaid;

    // Fund for dev will be locked in this contract and distributed during in 180days.
    address public devAddr;
    uint public devDistributeRate = 0;
    uint public lastDistributeTime = 0;
    uint public devFinishTime = 0;
    // 15% of NECO for Dev Fund
    uint public devFundAmount = 150000 * 1e18;
    uint public devDistributeDuration = 180 days;

    // decreasing period time
    uint public constant DURATION = 4 weeks;
    // 45% will be distributed via farming
    uint public initReward = 0;
    uint public totalReward = 450000 * 1e18;
    bool public initialized = false;

    // switch
    bool public haveStarted = false;

    event Stake(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);
    event Claim(address indexed to, uint amount);
    event Decreasing(uint amount);
    event Start();

    constructor(IERC20 _necoToken, IERC20 _lpToken) {
        necoToken = _necoToken;
        lpToken = _lpToken;
        devAddr = owner();
    }

    function totalSupply() public view returns(uint) {
        return _lpTotalSupply;
    }

    function balanceOf(address account) public view returns(uint) {
        return _lpBalances[account];
    }

    function stake(uint amount) external shouldStarted {
        updateRewards(msg.sender);
        checkDecreasing();
        require(!address(msg.sender).isContract(), "Please use your individual account.");
        _lpTotalSupply = _lpTotalSupply.add(amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        distributeDevFund();
        if (!_addressSet.contains(msg.sender)) {
            _addressSet.add(msg.sender);
        }
        emit Stake(msg.sender, amount);
    }

    function withdraw(uint amount) external shouldStarted {
        updateRewards(msg.sender);
        checkDecreasing();
        require(amount <= _lpBalances[msg.sender] && _lpBalances[msg.sender] > 0, "Bad withdraw.");
        _lpTotalSupply = _lpTotalSupply.sub(amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
        distributeDevFund();
        emit Withdraw(msg.sender, amount);
    }

    function claim(uint amount) external {
        require(amount <= rewards[msg.sender] && rewards[msg.sender] > 0, "Bad claim.");
        updateRewards(msg.sender);
        checkDecreasing();
        rewards[msg.sender] = rewards[msg.sender].sub(amount);
        necoToken.safeTransfer(msg.sender, amount);
        distributeDevFund();
        emit Claim(msg.sender, amount);
    }

    function checkDecreasing() internal {
        if (block.timestamp >= halvingTime) {
            initReward = initReward.mul(50).div(100);
            rewardRate = initReward.div(DURATION);
            halvingTime = halvingTime.add(DURATION);

            updateRewards(msg.sender);
            emit Decreasing(initReward);
        }
    }

    function getRewardsAmount(address account) public view returns(uint) {
        return balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function rewardPerToken() public view returns (uint) {
        if (_lpTotalSupply == 0) {
            return rewardPerLPToken;
        }
        return rewardPerLPToken
            .add(Math.min(block.timestamp, halvingTime)
                    .sub(lastUpdateTime)
                    .mul(rewardRate)
                    .mul(1e18)
                    .div(_lpTotalSupply)
            );
    }

    function updateRewards(address account) internal {
        rewardPerLPToken = rewardPerToken();
        lastUpdateTime = lastRewardTime();
        if (account != address(0)) {
            rewards[account] = getRewardsAmount(account);
            userRewardPerTokenPaid[account] = rewardPerLPToken;
        }
    }

    function lastRewardTime() public view returns (uint) {
        return Math.min(block.timestamp, halvingTime);
    }

    function initData() external onlyOwner {
        uint necoAmountRequired = devFundAmount.add(totalReward);
        necoToken.transferFrom(msg.sender, address(this), necoAmountRequired);
        initReward = totalReward.div(2);
        initialized = true;
    }

    function startFarming() external onlyOwner {
        require(initialized, "need to call initData funciton firstly.");
        require(necoToken.balanceOf(address(this)) > 0, "insufficient NECO token");
        updateRewards(address(0));
        rewardRate = initReward.div(DURATION);

        devDistributeRate = devFundAmount.div(devDistributeDuration);
        devFinishTime = block.timestamp.add(devDistributeDuration);

        lastUpdateTime = block.timestamp;
        lastDistributeTime = block.timestamp;
        halvingTime = block.timestamp.add(DURATION);

        haveStarted = true;
        emit Start();
    }

    function stopFarming() external onlyOwner {
        haveStarted = false;
    }

    function transferDevAddr(address newAddr) public onlyDev {
        require(newAddr != address(0), "zero addr");
        devAddr = newAddr;
    }

    function distributeDevFund() internal {
        uint nowTime = Math.min(block.timestamp, devFinishTime);
        uint fundAmount = nowTime.sub(lastDistributeTime).mul(devDistributeRate);
        necoToken.safeTransfer(devAddr, fundAmount);
        lastDistributeTime = nowTime;
    }

    function emergencyWithdraw() external onlyOwner {
        necoToken.transfer(owner(), necoToken.balanceOf(address(this)));
    }

    function getStakedAccountAmount() view public returns(uint) {
        return _addressSet.length();
    }

    function getStakedAccountById(uint index) view public returns(address) {
        return _addressSet.at(index);
    }

    /**
        Modifiers
     */
    modifier onlyDev() {
        require(msg.sender == devAddr, "This is only for dev.");
        _;
    }

    modifier shouldStarted() {
        require(haveStarted == true, "Have not started.");
        _;
    }
}