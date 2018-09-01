App = {
     web3Provider: null,
     contracts: {},
     account: 0x0,

     init: function() {
          /*
           * Replace me...
           */

          return App.initWeb3();
     },

     initWeb3: function() {
          // initialize web3
            if(typeof web3 != undefined) {
                  // reuse the provider of the web3 object injected by MetaMask
                  App.web3Provider = web3.currentProvider;
            } else {
                  // either create a new provider, here connecting to Ganache
                  App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545')
                  // instantiate a new web3 object
                  web3 = new Web3(App.web3Provider);
                  // or handle the case that the user does not have MetaMask by showing her a message asking her to install Metamask
            }
          return App.initContract();
     },

     initContract: function() {
      $.getJSON('TikkunToken.json', function(tikkunTokenArtifact){
            // get the contract artifact file and use it to instantiate a truffle contract abstraction
            App.contracts.TikkunToken = TruffleContract(tikkunTokenArtifact);
            // set the provider for our contract
            App.contracts.TikkunToken.setProvider(App.web3Provider);
            // retrieve zombies from the contract
            App.calculateInterest();
            //update account info
            return App.displayAccountInfo();
        });
      },

      displayAccountInfo: function () {
            // get current account information
            web3.eth.getCoinbase(function (err, account) {
            // if there is no error
            if (err === null) {
            //set the App object's account variable
                  App.account = account;
                  // insert the account address in the p-tag with id='account'
                  $("#account").text(account);
            }
            });
            
            // retrieve the balance corresponding to that account
            App.contracts.TikkunToken.deployed().then(function (instance) {
             // insert the balance in the p-tag with id='accountBalance'
            return instance.balanceOf(App.account);
            }).then(function(balance){
                  
                  $("#accountBalance").text(balance + " TKK");
            });
      },   
      
      buyTKK: function() {
            var _amt_buying = $("#amtbuying").val();
            // if the value was not provided
            if (_amt_buying.trim() == '') {
                  // we cannot but tokens
                  return false;
            }
             // get the instance of the ZombieOwnership contract
            App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.mint(_amt_buying, App.account, {from:App.account});
                  }).then(function(result){
                        console.log(result.logs);
                  });
            App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.totalSupply();
                  }).then(function(result){
                        console.log(result);
                  });
                  // log the error if there is one
      },

      redeemRands: function() {
            var _amt_redeeming = $("#amtRedeemed").val();
            // if the value was not provided
            if (_amt_redeeming.trim() == '') {
                  // we cannot but tokens
                  return false;
            }
            console.log("about to redeem rands");
             // get the instance of the ZombieOwnership contract
            App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.withDraw(App.account, _amt_redeeming, {from:App.account});
                  }).then(function(result){

                        console.log(result.logs);
                  }).catch(e => {
                        console.log(e);
                  });
            App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.totalSupply();
                  }).then(function(result){
                        console.log(result);
                  });
                  // log the error if there is one
      },

      transfer: function() {
            var _receiver_address= $("#receiverAddress").val();
            var _amt_transfering = $("#amtTransfering").val();
            // if the value was not provided
            if (_amt_transfering.trim() == '') {
                  // we cannot transfer tokens
                  return false;
            }
            if (_receiver_address.trim() == '') {
                  // we cannot transfer tokens
                  return false;
            }
            App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.transfer(_receiver_address, _amt_transfering, {from:App.account, gas: 6000000});
                  }).then(function(result){
                        console.log(result.logs);
                  }).catch(e => {
                        console.log(e);
                  });
      },

      calculateInterest: function() {
            var now = new Date();
            var millisTill12 = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 14, 05, 0, 0) - now;
            if (millisTill12 < 0) {
                  millisTill12 += 86400000; // it's after 12am, try 12am tomorrow.
             }
             setTimeout(function(){ 
                   App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.calculateInterest(App.account, {from:App.account});
                  }).then(function(result){
                        App.payInterest();
                        console.log(result.logs);
                        alert("interest paid!! ", +result);
                  });},
                  millisTill12);
      },

      payInterest: function() {
            var now = new Date();
            if (now.getDate() == 1) {
                  App.contracts.TikkunToken.deployed().then(function (instance) {
                  // call the buyTKK function, 
                  // passing the amount being bought and the transaction parameters
                  return instance.payInterest(App.account, {from:App.account});
                  }).then(function(result){
                        console.log(result.logs);
                  });
                  App.contracts.TikkunToken.deployed().then(function (instance) {
                        // call the buyTKK function, 
                        // passing the amount being bought and the transaction parameters
                        return instance.clearInterest(App.account);
                        }).then(function(result){
                              console.log(result.logs);
                        });
            }
      },
};

$(function() {
     $(window).load(function() {
          App.init();
     });
});