const GGToken = artifacts.require("GGtoken");

module.exports = function(deployer) {
  deployer.deploy(GGToken);
};
