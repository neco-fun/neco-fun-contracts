const FarmingPool = artifacts.require("FarmingPool");
const NecoToken = artifacts.require("NecoToken");
const FarmingLPToken = artifacts.require("FarmingLPToken");

module.exports = function (deployer, network, accounts) {
  deployer.deploy(FarmingLPToken).then(function () {
    return deployer.deploy(
      FarmingPool,
      NecoToken.address,
      FarmingLPToken.address
    );
  });
};
