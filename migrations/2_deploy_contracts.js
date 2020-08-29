const GGToken = artifacts.require("GGToken");
const GGTokenSale = artifacts.require("GGTokenSale");

module.exports = function(deployer) {
  deployer.deploy(GGToken, 10000).then(function() {
  	//Token price is 0.0001 Ether
  	var tokenPrice = 100000000000000;
  	return deployer.deploy(GGTokenSale, GGToken.address, tokenPrice);
  });
};
