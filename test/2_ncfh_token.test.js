const NecoFishToken = artifacts.require("NecoFishingToken");

contract("ncfhToken", ([Tom, Jerry, Rose]) => {
  it("should have correct initial data.", async () => {
    const ncfhToken = await NecoFishToken.deployed();
    const name = await ncfhToken.name();
    const symbol = await ncfhToken.symbol();
    const locked = await ncfhToken.transferLocked();

    assert.equal(name.valueOf(), "NecoFishing");
    assert.equal(symbol.valueOf(), "NFISH");
    assert.equal(locked.valueOf(), true);
  });

  it("should have a correct mint function", async () => {
    const ncfhToken = await NecoFishToken.deployed();

    // test when mintOperationForOwnerLocked is false
    await ncfhToken.addMinter(Tom);
    await ncfhToken.mint(Jerry, 1000, { from: Tom });
    assert(await ncfhToken.balanceOf(Jerry).valueOf(), 1000);

    // test when mintOperationForOwnerLocked is true
    await ncfhToken.enableMintOperationForOwnerLocked();
    let err = null;
    try {
      await ncfhToken.mint(Jerry, 1000, { from: Tom });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    // test when Jerry is not a minter
    err = null;
    try {
      await ncfhToken.mint(Jerry, 1000, { from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    // test when Jerry is a minter
    await ncfhToken.addMinter(Jerry);
    await ncfhToken.mint(Tom, 1000, { from: Jerry });
    assert(await ncfhToken.balanceOf(Tom).valueOf(), 1000);
  });

  it("should have a good goingToMint function", async () => {
    const ncfhToken = await NecoFishToken.deployed();

    await ncfhToken.changeUnlockTimeDuration(5);

    await ncfhToken.goingToMint(Rose, 1000);
    assert.equal(await ncfhToken.mintTo().valueOf(), Rose);
    assert.equal(await ncfhToken.mintAmount().valueOf(), 1000);
    assert.equal(
      (await ncfhToken.operationUnlockTime("mint").valueOf()) != 0,
      true
    );

    let err = null;
    try {
      await ncfhToken.releaseMint();
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    // setTimeout(async () => {
    //   await ncfhToken.releaseMint();
    //   assert(await ncfhToken.balanceOf(Rose).valueOf(), 1000);
    // }, 10);
  });

  it("cannot transfer token when transfer function is locked", async () => {
    const ncfhToken = await NecoFishToken.deployed();

    let err = null;
    try {
      await ncfhToken.transfer(Tom, 100, { from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    await ncfhToken.transfer(Jerry, 100, { from: Tom });
    assert.equal(await ncfhToken.balanceOf(Jerry).valueOf(), 1100);
  });

  it("can transfer token when transfer function is unlocked", async () => {
    const ncfhToken = await NecoFishToken.deployed();
    await ncfhToken.unlockTransfer();
    await ncfhToken.transfer(Tom, 100, { from: Jerry });
    assert.equal(await ncfhToken.balanceOf(Tom).valueOf(), 1000);
    assert.equal(await ncfhToken.balanceOf(Jerry).valueOf(), 1000);
  });

  it("should have a good transferFrom function", async () => {
    const ncfhToken = await NecoFishToken.deployed();
    await ncfhToken.approve(Rose, 100000, { from: Tom });
    await ncfhToken.transferFrom(Tom, Rose, 100, { from: Rose });
    assert.equal(await ncfhToken.balanceOf(Rose).valueOf(), 100);
  });

  it("can burn my own token", async () => {
    const ncfhToken = await NecoFishToken.deployed();
    await ncfhToken.burn(100, { from: Jerry });
    assert.equal(await ncfhToken.balanceOf(Jerry).valueOf(), 900);
  });

  it("should have a good burnFrom function", async () => {
    const ncfhToken = await NecoFishToken.deployed();
    await ncfhToken.addBurner(Tom);
    await ncfhToken.approve(Tom, 100000, { from: Jerry });
    await ncfhToken.burnFrom(Jerry, 100);
    assert.equal(await ncfhToken.balanceOf(Jerry).valueOf(), 800);
  });
});
