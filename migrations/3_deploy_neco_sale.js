const NecoSaleContract = artifacts.require("NecoSaleContract");
const NecoToken = artifacts.require("NecoToken");
const BUSD = artifacts.require("BUSD");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(
    NecoSaleContract,
    NecoToken.address,
    BUSD.address
  );
};
