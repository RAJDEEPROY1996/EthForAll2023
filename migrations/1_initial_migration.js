const RationDistribution = artifacts.require("rationDistribution");

module.exports = function (deployer) {
  deployer.deploy(RationDistribution);
};
