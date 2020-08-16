pragma solidity >=0.4.21 <0.7.0;

import "./GGToken.sol";

contract GGTokenSale {

	address admin;
	GGToken public tokenContract;
	uint256 public tokenPrice;
	uint256 public tokensSold;

	event Sell(
		address _buyer,
		uint256 _amount
	);

	constructor(GGToken _tokenContract, uint256 _tokenPrice) public {
		//Assign an admin
		admin = msg.sender;
		//Token Contract
		tokenContract = _tokenContract;
		//Token Price
		tokenPrice = _tokenPrice;
	}

	//Multiply function
	function multiply(uint x, uint y) internal pure returns (uint z) {
		require(y == 0 || (z = x * y) / y == x);
	}

	//Buy Tokens
	function buyTokens(uint256 _numberOfTokens) public payable {
		//Require that value is equal to tokens
		require(msg.value == multiply(_numberOfTokens, tokenPrice));
		//Require that the contract has enough tokens
		require(tokenContract.balanceOf(address(this)) >= _numberOfTokens);
		//Require that a transfer is successful
		require(tokenContract.transfer(msg.sender, _numberOfTokens));
		//Keep track of tokens sold
		tokensSold += _numberOfTokens;
		//Emit sell event
		emit Sell(msg.sender, _numberOfTokens);
	}

	//Ending Token GGTokenSale
	function endSale() public {
		//Require admin
		require(msg.sender == admin);
		//Transfer remaining GGTokens to admin
		require(tokenContract.transfer(admin, tokenContract.balanceOf(address(this))));
	}

}