const NecoToken = artifacts.require("NecoToken");
const NecoFishingToken = artifacts.require("NecoFishingToken");
const USDC = artifacts.require("USDC");

module.exports = function (deployer) {
  deployer.deploy(NecoToken);
  deployer.deploy(NecoFishingToken);
  deployer.deploy(USDC);
};
