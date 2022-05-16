const GGToken = artifacts.require("GGToken");
const GGTokenSale = artifacts.require("GGTokenSale");
const Wager = artifacts.require("Wager");

module.exports = function(deployer) {
  deployer.deploy(GGToken, 1000000000).then(function() {
  	//Token price is 0.0001 Ether
  	var tokenPrice = 1000000000000000;
  	return deployer.deploy(GGTokenSale, GGToken.address, tokenPrice);
  }).then(function() {
	  return deployer.deploy(Wager, GGToken.address);
  });
};
