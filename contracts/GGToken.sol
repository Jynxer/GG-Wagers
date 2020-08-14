pragma solidity >=0.4.21 <0.7.0;

contract GGToken {

	//Name
	string public name = "GG Token";
	//Symbol
	string public symbol = 'GGEZ';
	//Standard
	string public standard = 'GG Token v1.0';

	//Total Supply
	uint256 public totalSupply;

	//Transfer Event
	event Transfer(
		address indexed _from,
		address indexed _to,
		uint256 _value
	);

	mapping(address => uint256) public balanceOf;

	//Constructor
	constructor(uint256 _initialSupply) public {
		balanceOf[msg.sender] = _initialSupply;
		totalSupply = _initialSupply;
	}

	//Transfer
	function transfer(address _to, uint256 _value) public returns (bool success) {
		//Exception if account doesn't have the funds
		require(balanceOf[msg.sender] >= _value);
		//Transfer the balance
		balanceOf[msg.sender] -= _value;
		balanceOf[_to] += _value;
		//Emit Transfer Event
		emit Transfer(msg.sender, _to, _value);
		//Return a boolean
		return true;
	}

}