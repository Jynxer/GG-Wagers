App = {
	web3Provider: null,
	contracts: {},
	account: '0x0',
	loading: false,
	tokenPrice: 1000000000000000,
	tokensSold: 0,
	tokensAvailable: 10000000,

	init: function() {
		console.log("App initialised...");
		return App.initWeb3();
	},

	initWeb3: function() {
		if(typeof web3 !== 'undefined') {
			//If a web3 instance is already provided by metamask
			App.web3Provider = web3.currentProvider;
			web3 = new Web3(web3.currentProvider);
		} else {
			//Specify default instance if no web3 instance provided
			App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
			web3 = new Web3(App.web3Provider);
		}
		return App.enableUser();
	},

	enableUser: async function() {
		const accounts = await ethereum.enable();
    	const account = accounts[0];
    	App.account = account;
    	return App.initContracts();
	},

	initContracts: function() {
		$.getJSON("GGTokenSale.json", function(ggTokenSale) {
			App.contracts.GGTokenSale = TruffleContract(ggTokenSale);
			App.contracts.GGTokenSale.setProvider(App.web3Provider);
			App.contracts.GGTokenSale.deployed().then(function(ggTokenSale) {
				console.log("GG Token Sale Address:" , ggTokenSale.address);
			})
		}).done(function() {
			$.getJSON("GGToken.json", function(ggToken) {
				App.contracts.GGToken = TruffleContract(ggToken);
				App.contracts.GGToken.setProvider(App.web3Provider);
				App.contracts.GGToken.deployed().then(function(ggToken) {
					console.log("GG Token Address:" , ggToken.address);
				});
				App.listenForEvents();
				return App.render();
			});
		})
	},

	//Listen for events emitted from the contract
	listenForEvents: function() {
		App.contracts.GGTokenSale.deployed().then(function(instance) {
			instance.Sell({}, {
				fromBlock: 0,
				toBlock: 'latest'
			}).watch(function(error, event) {
				console.log("event triggered", event);
				App.render();
			})
		})
	},

	render: function() {
		if(App.loading) {
			return;
		}
		App.loading = true;

		var loader = $('#loader');
		var content = $('#content');

		loader.show();
		content.hide()

		//Load account data
		web3.eth.getCoinbase(function(err, account) {
			if(err === null) {
				App.account = account;
				$('#accountAddress').html("Your Account: " + account);
			}
		})

		//Load token sale contract
		App.contracts.GGTokenSale.deployed().then(function(instance) {
			ggTokenSaleInstance = instance;
			return ggTokenSaleInstance.tokenPrice();
		}).then(function(tokenPrice) {
			App.tokenPrice = tokenPrice;
			$('.token-price').html(web3.fromWei(App.tokenPrice, "ether").toNumber());
			return ggTokenSaleInstance.tokensSold();
		}).then(function(tokensSold) {
			App.tokensSold = tokensSold.toNumber();
			$('.tokens-sold').html(App.tokensSold);
			$('.tokens-available').html(App.tokensAvailable);

			var progressPercent = (App.tokensSold / App.tokensAvailable) * 100;
			$('#progress').css('width', progressPercent + '%');

			//Load token contract
			App.contracts.GGToken.deployed().then(function(instance) {
				ggTokenInstance = instance;
				return ggTokenInstance.balanceOf(App.account);
			}).then(function(balance) {
				$('.gg-balance').html(balance.toNumber());
				App.loading = false;
				loader.hide();
				content.show();
			})
		});
	},

	buyTokens: function() {
		$('#content').hide();
		$('#loader').show();
		var numberOfTokens = $('#numberOfTokens').val();
		App.contracts.GGTokenSale.deployed().then(function(instance) {
			return instance.buyTokens(numberOfTokens, {
				from: App.account,
				value: numberOfTokens * App.tokenPrice,
				gas: 500000
			});
		}).then(function(result) {
			console.log("Tokens bought...");
			//Wait for Sell event
		});
	}
}

$(function() {
	$(window).load(function() {
		App.init();
	})
});