// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.21 <0.9.0;

import "./Wager.sol";

contract GGToken {
    //Name
    string public name = "GG Token";
    //Symbol
    string public symbol = "GG";
    //Standard
    string public standard = "GG Token v1.0";

    WagerContract public wagerContract;

    //Total Supply
    uint256 public totalSupply;

    //Transfer Event
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    //Approve Event
    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _value
    );

    //Account Balances
    mapping(address => uint256) public balanceOf;
    //Allowance
    mapping(address => mapping(address => uint256)) public allowance;

    //Constructor
    constructor(uint256 _initialSupply) {
        //Set initial supply
        balanceOf[msg.sender] = _initialSupply;
        totalSupply = _initialSupply;
        //transfer(address(wagerContract), 100);
    }

    //Transfer
    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
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

    //Delegated Transfer

    //Approve
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        //Allowance
        allowance[msg.sender][_spender] = _value;
        //Approval event
        emit Approval(msg.sender, _spender, _value);
        //Return a boolean
        return true;
    }

    //TransferFrom
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        //Require _from has enough tokens
        require(_value <= balanceOf[_from]);
        //Require allowance is big enough
        require(_value <= allowance[_from][msg.sender]);
        //Change the balance
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        //Update the allowance
        allowance[_from][msg.sender] -= _value;
        //Transfer Event
        emit Transfer(_from, _to, _value);
        //Returns a boolean
        return true;
    }
}
