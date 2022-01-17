const NecoFishToken = artifacts.require("NecoFishingToken");

contract("nfishToken", ([Tom, Jerry, Rose]) => {
  it("should have correct initial data.", async () => {
    const nfishToken = await NecoFishToken.deployed();
    const name = await nfishToken.name();
    const symbol = await nfishToken.symbol();
    const locked = await nfishToken.transferLocked();

    assert.equal(name.valueOf(), "NecoFishing");
    assert.equal(symbol.valueOf(), "NFISH");
    assert.equal(locked.valueOf(), true);
  });

  it("should have a correct mint function", async () => {
    const nfishToken = await NecoFishToken.deployed();

    // test when mintOperationForOwnerLocked is false
    await nfishToken.addMinter(Tom);
    await nfishToken.mint(Jerry, 1000, { from: Tom });
    assert(await nfishToken.balanceOf(Jerry).valueOf(), 1000);

    // test when mintOperationForOwnerLocked is true
    await nfishToken.enableMintOperationForOwnerLocked();
    let err = null;
    try {
      await nfishToken.mint(Jerry, 1000, { from: Tom });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    // test when Jerry is not a minter
    err = null;
    try {
      await nfishToken.mint(Jerry, 1000, { from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    // test when Jerry is a minter
    await nfishToken.addMinter(Jerry);
    await nfishToken.mint(Tom, 1000, { from: Jerry });
    assert.equal(await nfishToken.balanceOf(Tom).valueOf(), 1000);
  });

  it("should have a good goingToMint function", async () => {
    const nfishToken = await NecoFishToken.deployed();

    // await nfishToken.changeUnlockTimeDuration(5);

    await nfishToken.goingToMint(Rose, 1000);
    assert.equal(await nfishToken.mintTo().valueOf(), Rose);
    assert.equal(await nfishToken.mintAmount().valueOf(), 1000);
    assert.equal(
      (await nfishToken.operationUnlockTime("mint").valueOf()) != 0,
      true
    );

    let err = null;
    try {
      await nfishToken.releaseMint();
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
    const nfishToken = await NecoFishToken.deployed();

    let err = null;
    try {
      await nfishToken.transfer(Tom, 100, { from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    await nfishToken.transfer(Jerry, 100, { from: Tom });
    assert.equal(await nfishToken.balanceOf(Jerry).valueOf(), 1100);
  });

  it("can transfer token when transfer function is unlocked", async () => {
    const nfishToken = await NecoFishToken.deployed();
    await nfishToken.unlockTransfer();
    await nfishToken.transfer(Tom, 100, { from: Jerry });
    assert.equal(await nfishToken.balanceOf(Tom).valueOf(), 1000);
    assert.equal(await nfishToken.balanceOf(Jerry).valueOf(), 1000);
  });

  it("should have a good transferFrom function", async () => {
    const nfishToken = await NecoFishToken.deployed();
    await nfishToken.approve(Rose, 100000, { from: Tom });
    await nfishToken.transferFrom(Tom, Rose, 100, { from: Rose });
    assert.equal(await nfishToken.balanceOf(Rose).valueOf(), 100);
  });

  it("can burn my own token", async () => {
    const nfishToken = await NecoFishToken.deployed();
    await nfishToken.burn(100, { from: Jerry });
    assert.equal(await nfishToken.balanceOf(Jerry).valueOf(), 900);
  });

  it("should have a good burnFrom function", async () => {
    const nfishToken = await NecoFishToken.deployed();
    await nfishToken.addBurner(Tom);
    await nfishToken.approve(Tom, 100000, { from: Jerry });
    await nfishToken.burnFrom(Jerry, 100);
    assert.equal(await nfishToken.balanceOf(Jerry).valueOf(), 800);
  });
});
