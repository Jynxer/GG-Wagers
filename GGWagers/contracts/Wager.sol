// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.4.21 <0.9.0;

import "./GGToken.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract WagerContract {
    GGToken public tokenContract;
    IERC20 public tokenInterface;
    uint256 wagerId = 0;
    Wager[] wagers;
    mapping(uint256 => address) competitors;

    constructor(GGToken _tokenContract) {
        tokenContract = _tokenContract;
        tokenInterface = IERC20(address(tokenContract));
        //tokenContract.balanceOf(msg.sender) = 1000;
        //tokenContract.transfer(msg.sender, 1000);
    }

    modifier hasFunds(address account, uint256 amount) {
        require(
            tokenContract.balanceOf(account) >= amount,
            "Insufficient funds."
        );
        _;
    }

    struct Wager {
        uint256 id;
        uint256 validUntil;
        uint256 wagerAmount;
        address creator;
        bool isActive;
        bool completed;
    }

    event WagerCreated(
        uint256 id,
        uint256 validUntil,
        uint256 wagerAmount,
        address creator
    );
    event WagerAccepted(uint256 wagerId, address competitor);
    event WagerCompleted(
        uint256 wagerId,
        address winnerAccount,
        uint256 winnings
    );
    event WagerCancelled(uint256 wagerId);

    function getMoney(uint256 _amount) public {
        tokenContract.transfer(msg.sender, _amount);
        //tokenContract.balanceOf(msg.sender) += _amount;
    }

    // Inistatiate new Wager object and push it to the 'wagers' array.
    function createWager(uint256 _wagerAmount)
        public
        payable
        hasFunds(msg.sender, _wagerAmount)
    {
        bool success = tokenContract.transferFrom(
            msg.sender,
            address(this),
            _wagerAmount
        );
        require(success, "Transfer unsuccessful");
        // Assert that the exact wager amount has been payed
        require(msg.value == _wagerAmount, "Exact wager amount not payed");
        // Take the wager amount out of the creator's balance
        //tokenContract.balanceOf(msg.sender) -= _wagerAmount;

        // Get copy of wagerId rather than assigning the memory address
        uint256 newWagerId = wagerId;
        // Calculate the blocktime in 5 minutes time (wager timeout)
        uint256 newValidUntil = block.timestamp + (20 * 1 minutes);
        // Instatiate new Wager object
        Wager memory newWager = Wager({
            id: newWagerId,
            validUntil: newValidUntil,
            wagerAmount: _wagerAmount,
            creator: msg.sender,
            isActive: false,
            completed: false
        });
        // Push new Wager object to the 'wagers' array
        wagers.push(newWager);
        // Increment the global wager ID variable by 1
        wagerId += 1;
        // Emit an event to log the creation of the wager
        emit WagerCreated(newWagerId, newValidUntil, _wagerAmount, msg.sender);
    }

    // Competitor accepts a wager
    function acceptWager(uint256 _wagerId) public payable {
        // Wager must be accepted within 20 minutes
        require(
            wagers[_wagerId].validUntil >= block.timestamp,
            "Wager must be accepted within 20 minutes"
        );
        // Wagers cannot be accepted if active
        require(
            wagers[_wagerId].isActive == false,
            "Wagers cannot be accepted if active"
        );
        // Creator cannot be the same as competitor
        require(
            msg.sender != wagers[_wagerId].creator,
            "Creator cannot be the same as competitor"
        );
        // Right amount must be payed in
        require(
            msg.value == wagers[_wagerId].wagerAmount,
            "Correct amount must be payed to accept wager"
        );
        // Assert that the exact wager amount has been payed                                            Must revisit when refactoring to separate contracts
        //require(msg.value == wagers[_wagerId].wagerAmount, "Exact wager amount not payed");
        // The accepted wager must be active
        require(wagers[_wagerId].completed == false);
        // Take the wager amount out of the creator's balance
        //tokenContract.balanceOf(msg.sender) -= wagers[_wagerId].wagerAmount;
        // Map the competitor's address to the Wager object
        competitors[_wagerId] = msg.sender;
        // Set the wager to 'active'
        wagers[_wagerId].isActive = true;
        // Emit an event to log the acceptance of the wager
        emit WagerAccepted(_wagerId, msg.sender);
    }

    // A wager is completed and the winnings should be payed out
    function completeWager(uint256 _wagerId, bool creatorWon) public {
        // Wagers cannot be completed if inactive
        require(
            wagers[_wagerId].isActive == true,
            "Wagers cannot be completed if inactive"
        );
        // Contract has the balance to pay out
        require(
            tokenContract.balanceOf(address(this)) >=
                (2 * wagers[_wagerId].wagerAmount),
            "Contract must have enough balance to pay winner"
        );
        // Instatiate winner account for scope
        address _winnerAccount;
        if (creatorWon) {
            // Set winner account to creator account if the creator won
            //_winnerAccount = payable(wagers[_wagerId].creator);
            _winnerAccount = wagers[_wagerId].creator;
        } else {
            // Set winner account to competitor account if the competitor won
            //_winnerAccount = payable(competitors[_wagerId]);
            _winnerAccount = competitors[_wagerId];
        }
        // Make the winnerAccount payable
        //address payable payableWinner = _winnerAccount;
        // Add winnings to winner's balance
        // tokenContract.balanceOf(_winnerAccount) += (2 *
        //     wagers[_wagerId].wagerAmount);
        tokenContract.transfer(
            _winnerAccount,
            (2 * wagers[_wagerId].wagerAmount)
        );
        // Set the wager to 'completed'
        wagers[_wagerId].completed = true;
        // Set the wager to 'inactive'
        wagers[_wagerId].isActive = false;
        // Emit an event to log the completion of the wager
        emit WagerCompleted(
            _wagerId,
            _winnerAccount,
            (2 * wagers[_wagerId].wagerAmount)
        );
    }

    // A wager is cancelled and the wager amount is payed back to the creator
    function cancelWager(uint256 _wagerId) public {
        // Wagers cannot be cancelled while active
        require(
            wagers[_wagerId].isActive == false,
            "Wagers cannot be cancelled while active"
        );
        // Wagers cannot be cancelled once complete
        require(
            wagers[_wagerId].completed == false,
            "Wagers cannot be cancelled once complete"
        );
        // Only the creator can cancel a wager
        require(
            msg.sender == wagers[_wagerId].creator,
            "Can only cancel wagers created by you"
        );
        // Set the wager to 'completed'
        wagers[_wagerId].completed = true;
        // Pay the creator back the wager amount
        //tokenContract.balanceOf(msg.sender) += wagers[_wagerId].wagerAmount;
        tokenContract.transfer(msg.sender, wagers[_wagerId].wagerAmount);
        // Set the wager to 'inactive'
        wagers[_wagerId].isActive = false;
        // Emit an event to log the cancellation of the wager
        emit WagerCancelled(_wagerId);
    }
}
