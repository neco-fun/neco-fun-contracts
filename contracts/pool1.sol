// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./INecoToken.sol";

contract StakeNECOToNECO is Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    using Address for address;

    INecoToken public neco;
    IERC20 public lpToken;

    //LP token balances
    mapping(address => uint256) private _lpBalances;
    uint private _lpTotalSupply;

    // decreasing period time
    uint256 public constant DURATION = 2 weeks;
    uint256 public initReward = 200000 * 1e18;
    bool public haveStarted = false;
    // next time of decreasing
    uint256 public halvingTime = 0;
    uint256 public lastUpdateTime = 0;
    // distribution of per second
    uint256 public rewardRate = 0;
    uint256 public rewardPerLPToken = 0;
    mapping(address => uint256) private rewards;
    mapping(address => uint256) private userRewardPerTokenPaid;


    // Something about dev.
    address public devAddr;
    uint256 public devDistributeRate = 0;
    uint256 public lastDistributeTime = 0;
    uint256 public devFinishTime = 0;
    uint256 public devFundAmount = 0 * 1e18;
    uint256 public devDistributeDuration = 180 days;

    event Stake(address indexed from, uint amount);
    event Withdraw(address indexed to, uint amount);
    event Claim(address indexed to, uint amount);
    event Decreasing(uint amount);
    event Start(uint amount);

    constructor(address _neco, address _lpToken) {
        neco = INecoToken(_neco);
        lpToken = IERC20(_lpToken);
        devAddr = owner();
    }

    function totalSupply() public view returns(uint256) {
        return _lpTotalSupply;
    }

    function balanceOf(address account) public view returns(uint256) {
        return _lpBalances[account];
    }

    function stake(uint amount) public shouldStarted {
        updateRewards(msg.sender);
        checkDecreasing();
        require(!address(msg.sender).isContract(), "Please use your individual account.");
        _lpTotalSupply = _lpTotalSupply.add(amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].add(amount);
        lpToken.safeTransferFrom(msg.sender, address(this), amount);
        distributeDevFund();
        emit Stake(msg.sender, amount);
    }

    function withdraw(uint amount) public shouldStarted {
        updateRewards(msg.sender);
        checkDecreasing();
        require(amount <= _lpBalances[msg.sender] && _lpBalances[msg.sender] > 0, "Bad withdraw.");
        _lpTotalSupply = _lpTotalSupply.sub(amount);
        _lpBalances[msg.sender] = _lpBalances[msg.sender].sub(amount);
        lpToken.safeTransfer(msg.sender, amount);
        distributeDevFund();
        emit Withdraw(msg.sender, amount);
    }

    function claim(uint amount) public shouldStarted {
        updateRewards(msg.sender);
        checkDecreasing();
        require(amount <= rewards[msg.sender] && rewards[msg.sender] > 0, "Bad claim.");
        rewards[msg.sender] = rewards[msg.sender].sub(amount);
        neco.transfer(msg.sender, amount);
        distributeDevFund();
        emit Claim(msg.sender, amount);
    }

    function checkDecreasing() internal {
        if (block.timestamp >= halvingTime) {
            initReward = initReward.mul(94).div(100);
            neco.mint(address(this), initReward);

            rewardRate = initReward.div(DURATION);
            halvingTime = halvingTime.add(DURATION);

            updateRewards(msg.sender);
            emit Decreasing(initReward);
        }
    }

    modifier shouldStarted() {
        require(haveStarted == true, "Have not started.");
        _;
    }

    function getRewardsAmount(address account) public view returns(uint256) {
        return balanceOf(account).mul(rewardPerToken().sub(userRewardPerTokenPaid[account]))
                .div(1e18)
                .add(rewards[account]);
    }

    function rewardPerToken() public view returns (uint256) {
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

    function lastRewardTime() public view returns (uint256) {
        return Math.min(block.timestamp, halvingTime);
    }

    function startFarming() external onlyOwner {
        updateRewards(address(0));
        rewardRate = initReward.div(DURATION);

        uint256 mintAmount = initReward.add(devFundAmount);
        neco.mint(address(this), mintAmount);
        devDistributeRate = devFundAmount.div(devDistributeDuration);
        devFinishTime = block.timestamp.add(devDistributeDuration);

        lastUpdateTime = block.timestamp;
        lastDistributeTime = block.timestamp;
        halvingTime = block.timestamp.add(DURATION);

        haveStarted = true;
        emit Start(mintAmount);
    }

    function transferDevAddr(address newAddr) public onlyDev {
        require(newAddr != address(0), "zero addr");
        devAddr = newAddr;
    }

    function distributeDevFund() internal {
        uint256 nowTime = Math.min(block.timestamp, devFinishTime);
        uint256 fundAmount = nowTime.sub(lastDistributeTime).mul(devDistributeRate);
        neco.transfer(devAddr, fundAmount);
        lastDistributeTime = nowTime;
    }

    modifier onlyDev() {
        require(msg.sender == devAddr, "This is only for dev.");
        _;
    }

    function lpTokenAddress() view public returns(address) {
        return address(lpToken);
    }

    function testMint() public onlyOwner {
        neco.mint(address(this), 1);
    }
}