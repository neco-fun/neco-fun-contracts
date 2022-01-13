const NecoSaleContract = artifacts.require("NecoSaleContract");
const NecoToken = artifacts.require("NecoToken");
const USDC = artifacts.require("USDC");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(
    NecoSaleContract,
    accounts[0],
    NecoToken.address,
    USDC.address
  );
};
