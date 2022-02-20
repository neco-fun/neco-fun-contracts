const NecoToken = artifacts.require("NecoToken");

contract("NecoToken", ([Tom, Jerry, Rose]) => {
  it("should have correct initial data.", async () => {
    const necoToken = await NecoToken.deployed();
    const name = await necoToken.name();
    const symbol = await necoToken.symbol();
    const locked = await necoToken.transferLocked();

    assert.equal(name.valueOf(), "NecoFun");
    assert.equal(symbol.valueOf(), "NECO");
    assert.equal(locked.valueOf(), true);
    assert.equal(
      await necoToken.balanceOf(Tom).valueOf(),
      "1000000000000000000000000"
    );
  });

  // it("cannot transfer token when transfer function is locked", async () => {
  //   const necoToken = await NecoToken.deployed();
  //   await necoToken.transfer(Jerry, 1000, { from: Tom });

  //   let err = null;
  //   try {
  //     await necoToken.transfer(Tom, 100, { from: Jerry });
  //   } catch (error) {
  //     err = error;
  //   }
  //   assert.ok(err instanceof Error);
  //   assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 1000);
  // });

  // it("can transfer token when transfer function is unlocked", async () => {
  //   const necoToken = await NecoToken.deployed();
  //   await necoToken.unlockTransfer();
  //   await necoToken.transfer(Tom, 100, { from: Jerry });
  //   assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 900);
  // });

  // it("can burn my own token", async () => {
  //   const necoToken = await NecoToken.deployed();
  //   await necoToken.burn(900, { from: Jerry });
  //   assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 0);
  // });

  it("need to pay tax for transfer", async () => {
    const necoToken = await NecoToken.deployed();
    await necoToken.unlockTransfer();
    await necoToken.changeTaxRate(10);
    assert.equal(await necoToken.taxRate().valueOf(), 10)
    await necoToken.changeTaxRecipient(Jerry)
    assert.equal(await necoToken.taxRecipient().valueOf(), Jerry)

    // await necoToken.transfer(Rose, 1000)
    // assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 100);
    // assert.equal(await necoToken.balanceOf(Rose).valueOf(), 900);

    await necoToken.approve(Tom, 1000)
    await necoToken.transferFrom(Tom, Rose, 1000)
    assert.equal(await necoToken.balanceOf(Jerry).valueOf(), 100);
    assert.equal(await necoToken.balanceOf(Rose).valueOf(), 900);
  })
});
