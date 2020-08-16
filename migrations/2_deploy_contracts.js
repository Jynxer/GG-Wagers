const GGToken = artifacts.require("GGToken");
const GGTokenSale = artifacts.require("GGTokenSale");

module.exports = function(deployer) {
  deployer.deploy(GGToken, 100000000).then(function() {
  	//Token price is 0.001 Ether
  	var tokenPrice = 1000000000000000;
  	return deployer.deploy(GGTokenSale, GGToken.address, tokenPrice);
  });
};
