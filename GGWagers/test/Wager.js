var GGToken = artifacts.require("GGToken");
var Wager = artifacts.require("Wager");

contract('Wager', function(accounts) {

	var tokenInstance;
    var wagerInstance;
    var creator = accounts[0];
	var competitor = accounts[1];

	it('correctly creates a new wager', function() {
		return GGToken.deployed().then(function(instance) {
			tokenInstance = instance;
			return Wager.deployed();
		}).then(function(instance) {
            wagerInstance = instance;
            return tokenInstance.balanceOf(creator);
        }).then(async function(balance) {
            assert.equal(balance.toNumber(), 1000000000, 'checking initial creator balance');
            await tokenInstance.approve(wagerInstance.address, 100);
            return await wagerInstance.createWager(100, {value: 100, from: creator, gasPrice: 200});
        }).then(function(receipt) {
            assert.equal(receipt.logs.length, 1, 'triggers one event');
			assert.equal(receipt.logs[0].event, 'WagerCreated', 'should be the "WagerCreated" event');
            assert.equal(receipt.logs[0].args.wagerAmount, 100, 'the wager amount is correct and has been payed accordingly');
            assert.equal(receipt.logs[0].args.creator, creator, 'creator should be msg.sender');
		// 	return tokenInstance.balanceOf(creator);
		// }).then(function(balance) {
        //     assert.equal(balance.toNumber(), 1000000000-100, 'creator account should be updated');
        });
	});

    it('correctly accepts a wager', function() {
        return GGToken.deployed().then(function(instance) {
            tokenInstance = instance;
            return Wager.deployed();
        }).then(function(instance) {
            wagerInstance = instance;
            return wagerInstance.acceptWager(30, {value: 100, from: competitor, gasPrice: 200});
        }).then(function(receipt) {
            assert.equal(receipt.logs.length, 1, 'triggers one event');
			assert.equal(receipt.logs[0].event, 'WagerAccepted', 'should be the "WagerAccepted" event');
            assert.equal(receipt.logs[0].args.competitor, competitor, 'should be accepted by the competitor account');
        });
    });

    it('correctly completes a wager', function() {
        return GGToken.deployed().then(function(instance) {
            tokenInstance = instance;
            return Wager.deployed();
        }).then(function(instance) {
            wagerInstance = instance;
            return wagerInstance.completeWager(30, true, {from: creator});
        }).then(function(receipt) {
            assert.equal(receipt.logs.length, 1, 'triggers one event');
			assert.equal(receipt.logs[0].event, 'WagerCompleted', 'should be the "WagerCompleted" event');
            assert.equal(receipt.logs[0].args.winnerAccount, creator, 'creator address should be the winner');
            assert.equal(receipt.logs[0].args.winnings, 200, 'winnings should be the sum of entry fees');
        });
    });

});