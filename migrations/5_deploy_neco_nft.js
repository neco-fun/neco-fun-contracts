const NecoNFT = artifacts.require("NecoNFT");

module.exports = function (deployer, network, accounts) {
    deployer.deploy(NecoNFT, "ipfs://");
};