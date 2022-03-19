const NecoToken = artifacts.require("NecoToken");

contract("NecoToken", ([Tom, Jerry, Rose, Lucy]) => {
  it("should have correct initial data.", async () => {
    const necoToken = await NecoToken.deployed();
    const name = await necoToken.name();
    const symbol = await necoToken.symbol();
    const locked = await necoToken.transferLocked();

    assert.equal(name.valueOf(), "Neco Fun");
    assert.equal(symbol.valueOf(), "NECO");
    assert.equal(locked.valueOf(), true);
    assert.equal(
      await necoToken.balanceOf(Tom).valueOf(),
      "0"
    );
  });

  it("should only allow owner to add minter", async function () {
    const necoToken = await NecoToken.deployed();
    await necoToken.addMinter(Tom, { from: Tom });
    await necoToken.addMinter(Jerry, { from: Tom });
    let err = null;
    try {
      await necoToken.addMinter(Rose, { from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    let tomIsMinter = await necoToken.minters(Tom);
    let jerryIsMinter = await necoToken.minters(Jerry);
    let roseIsMinter = await necoToken.minters(Rose);
    assert.equal(tomIsMinter.valueOf(), true);
    assert.equal(jerryIsMinter.valueOf(), true);
    assert.equal(roseIsMinter.valueOf(), false);
  });

  it("should only allow minter to mint token", async function () {
    const necoToken = await NecoToken.deployed();
    await necoToken.mint(Tom, 300, { from: Tom });
    await necoToken.mint(Rose, 200, { from: Jerry });
    let err = null;
    try {
      await necoToken.mint(Rose, 500, { from: Rose });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);

    const totalSupply = await necoToken.totalSupply();
    const tomBalance = await necoToken.balanceOf(Tom);
    const jerryBalance = await necoToken.balanceOf(Jerry);
    const RoseBalance = await necoToken.balanceOf(Rose);
    assert.equal(totalSupply.valueOf(), 500, "TotalSupply is not correct.");
    assert.equal(tomBalance.valueOf(), 300, "Tom's balance is not correct.");
    assert.equal(jerryBalance.valueOf(), 0, "Lucy's balance is not correct.");
    assert.equal(RoseBalance.valueOf(), 200, "Bobe's balance is not correct.");
  });

  // it("should support token transfers properly", async () => {
  //   const necoToken = await NecoToken.deployed();
  //   await necoToken.transfer(Jerry, 100, { from: Rose });
  //   const totalSupply = await necoToken.totalSupply();
  //   const tomBalance = await necoToken.balanceOf(Tom);
  //   const jerryBalance = await necoToken.balanceOf(Jerry);
  //   const roseBalance = await necoToken.balanceOf(Rose);
  //   assert.equal(totalSupply.valueOf(), 300, "TotalSupply is not correct.");
  //   assert.equal(tomBalance.valueOf(), 100, "Tom's balance is not correct.");
  //   assert.equal(jerryBalance.valueOf(), 100, "Lucy's balance is not correct.");
  //   assert.equal(roseBalance.valueOf(), 100, "Bobe's balance is not correct.");
  // });

  it("cannot transfer token when transfer function is locked", async () => {
    const necoToken = await NecoToken.deployed();
    await necoToken.addToTransferWhitelist(Tom);
    await necoToken.transfer(Jerry, 100, { from: Tom });

    let err = null;
    try {
      await necoToken.transfer(Tom, 100, { from: Jerry });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);
    assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 100);
  });

  it("can transfer token when transfer function is unlocked", async () => {
    const necoToken = await NecoToken.deployed();
    await necoToken.unlockTransfer();
    await necoToken.transfer(Tom, 100, { from: Jerry });
    assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 0);
  });

  it("can burn my own token", async () => {
    const necoToken = await NecoToken.deployed();
    await necoToken.burn(100, { from: Tom });
    assert.equal(await necoToken.balanceOf(Tom).valueOf(), 200);
  });

  it("need to pay tax for transfer", async () => {
    const necoToken = await NecoToken.deployed();
    await necoToken.changeTaxRate(10);
    assert.equal(await necoToken.taxRate().valueOf(), 10)
    await necoToken.changeTaxRecipient(Jerry)
    assert.equal(await necoToken.taxRecipient().valueOf(), Jerry)

    // await necoToken.transfer(Rose, 1000)
    // assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 100);
    // assert.equal(await necoToken.balanceOf(Rose).valueOf(), 900);

    await necoToken.approve(Tom, 100)
    await necoToken.transferFrom(Tom, Rose, 100)
    assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 10);
    assert.equal(await necoToken.balanceOf(Rose).valueOf(), 290);
  })

  it("should have a good amount limit function", async () => {
    const necoToken = await NecoToken.deployed();
    await necoToken.mint(Tom, '700000000000000000000', { from: Tom });
    let err = null;
    try {
      await necoToken.transfer(Lucy, '500000000000000000001', { from: Tom });
    } catch (error) {
      err = error;
    }
    assert.ok(err instanceof Error);
  })
});
