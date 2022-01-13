const NecoFishingToken = artifacts.require("NecoFishingToken");
const USDC = artifacts.require("USDC");
const NecoSaleContract = artifacts.require("NecoSaleContract");
const NECOToken = artifacts.require("NecoToken");

contract("NecoSaleContract", ([Tom, Jerry, Rose]) => {
  it("should have a good initial data", async () => {
    const necoSaleContract = await NecoSaleContract.deployed();
    const necoToken = await NECOToken.deployed();
    const usdc = await USDC.deployed();

    assert.equal(
      await necoSaleContract.necoToken().valueOf(),
      necoToken.address
    );
    assert.equal(await necoSaleContract.usdc().valueOf(), usdc.address);
    assert.equal(await necoSaleContract.devAddress().valueOf(), Tom);
    assert.equal(await necoSaleContract.saleStarted().valueOf(), false);
    assert.equal(await necoSaleContract.fcfsEnabled().valueOf(), false);
  });

  it("should have a good whitelist system", async () => {
    const necoSaleContract = await NecoSaleContract.deployed();
    await necoSaleContract.addToWhitelist(Tom);
    await necoSaleContract.addToWhitelist(Jerry);
    await necoSaleContract.addToWhitelist(Rose);
    assert.equal(await necoSaleContract.whitelist(Tom).valueOf(), true);
    assert.equal(await necoSaleContract.whitelist(Jerry).valueOf(), true);
    assert.equal(await necoSaleContract.whitelist(Rose).valueOf(), true);
    assert.equal(
      await necoSaleContract.getWhitelistAccountAmount().valueOf(),
      4
    );
    await necoSaleContract.removeFromWhitelist(Rose);
    assert.equal(
      await necoSaleContract.getWhitelistAccountAmount().valueOf(),
      3
    );
    for (let i = 0; i < 3; i++) {
      console.log(await necoSaleContract.getWhitelistAccountById(i));
    }
  });

  it("should have a good buy token function", async () => {
    const necoToken = await NECOToken.deployed();
    await necoToken.unlockTransfer();
    const usdc = await USDC.deployed();
    const necoSaleContract = await NecoSaleContract.deployed();
    await necoToken.approve(
      necoSaleContract.address,
      "50000000000000000000000",
      { from: Tom }
    );
    await necoSaleContract.depositNecoToken('50000000000000000000000');

    await necoSaleContract.startSale();
    await usdc.mint(Tom, "10000000000000000000000");
    await usdc.mint(Jerry, "10000000000000000000000");
    await usdc.approve(necoSaleContract.address, "10000000000000000000000", {
      from: Tom,
    });
    await usdc.approve(necoSaleContract.address, "10000000000000000000000", {
      from: Jerry,
    });
    await necoSaleContract.buyNecoToken("300000000", {
      from: Jerry,
    });
    assert.equal(
      await necoSaleContract.necoTokenAmountPerAccount(Jerry).valueOf(),
      "100000000000000000000"
    );
    for (let i = 0; i < 9; i++) {
      console.log(
        "Claimable amount is " +
          (await necoSaleContract.userClaimRoadMap(Jerry, i))
      );
    }

    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 0).valueOf(),
      "20000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 1).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 2).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 3).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 4).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 5).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 6).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 7).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 8).valueOf(),
      "10000000000000000000"
    );
    assert.equal(
      await necoSaleContract.userClaimRoadMap(Jerry, 9).valueOf(),
      "0"
    );
  });

  it("cannot withdraw before enabling withdraw function", async () => {
    const necoToken = await NECOToken.deployed();
    const usdc = await USDC.deployed();
    const necoSaleContract = await NecoSaleContract.deployed();

    let err = null;
    try {
      await necoSaleContract.claimToken({ from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    await necoSaleContract.enableClaim();
    for (let i = 0; i < 9; i++) {
      console.log(
        "index: " +
          i +
          "StartTime: " +
          (await necoSaleContract.claimTimes(i)).startTime
      );
      console.log(
        "index: " +
          i +
          "EndTime: " +
          (await necoSaleContract.claimTimes(i)).endTime
      );
    }

    console.log(
      "this is number " + (await necoSaleContract.getCurrentIndexOfClaim())
    );

    await necoToken.unlockTransfer();

    console.log(
      "current claimable amount: " +
        (await necoSaleContract.necoTokenClaimableAmount(Jerry))
    );

    await necoSaleContract.claimToken({ from: Jerry });
    assert.equal(
      await necoToken.balanceOf(Jerry).valueOf(),
      "20000000000000000000"
    );
  });
});
