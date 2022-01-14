const NecoToken = artifacts.require("NecoToken");
const NecoFishingToken = artifacts.require("NecoFishingToken");
const BUSD = artifacts.require("BUSD");

module.exports = function (deployer) {
  deployer.deploy(NecoToken);
  deployer.deploy(NecoFishingToken);
  deployer.deploy(BUSD);
};
