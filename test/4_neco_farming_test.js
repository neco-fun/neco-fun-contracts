const FarmingPool = artifacts.require("FarmingPool");
const NecoTokenContract = artifacts.require("NecoToken");
const FarmingLPToken = artifacts.require("FarmingLPToken");

contract("FarmingPool", ([Tom, Jerry, Rose]) => {
  it("should have correct initial data", async () => {
    const farmingPool = await FarmingPool.deployed();
    const necoToken = await NecoTokenContract.deployed();
    const farmingLPToken = await FarmingLPToken.deployed();

    assert.equal(await farmingPool.necoToken().valueOf(), necoToken.address);
    assert.equal(await farmingPool.lpToken().valueOf(), farmingLPToken.address);
    assert.equal(await farmingPool.totalSupply().valueOf(), 0);
    assert.equal(await farmingPool.initReward().valueOf(), 0);
    assert.equal(await farmingPool.totalReward().valueOf(), 0);
    assert.equal(await farmingPool.haveStarted().valueOf(), false);
    assert.equal(await farmingPool.devAddr().valueOf(), Tom);
  });

  it("should have a good initData function", async () => {
    const farmingPool = await FarmingPool.deployed();
    const necoToken = await NecoTokenContract.deployed();
    const farmingLPToken = await FarmingLPToken.deployed();
    await necoToken.unlockTransfer();
    console.log((await necoToken.balanceOf(Tom)).valueOf() + '')
    await necoToken.approve(farmingPool.address, "600000000000000000000000", {from: Tom})
    await farmingPool.initData('600000000000000000000000');
    assert.equal(
      await farmingPool.totalReward().valueOf(),
      "450000000000000000000000"
    );
    assert.equal(
      await farmingPool.initReward().valueOf(),
      "225000000000000000000000"
    );
  });

  it("should have a good stake function", async () => {
    const farmingPool = await FarmingPool.deployed();
    const necoToken = await NecoTokenContract.deployed();
    const farmingLPToken = await FarmingLPToken.deployed();

    await farmingLPToken.mint(Tom, "1000");
    await farmingLPToken.approve(farmingPool.address, "1000", { from: Tom });
    await farmingPool.startFarming();
    await farmingPool.stake("1000");
  });
});
