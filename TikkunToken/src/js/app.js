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
        
            //update account info
            App.displayAccountInfo();
        
            // show zombies owned by current user
            return App.reloadZombies();
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
            // retrieve the balance corresponding to that account
            web3.eth.getBalance(account, function (err, balance) {
                  // if there is no error
                  if (err === null) {
                        // insert the balance in the p-tag with id='accountBalance'
                        $("#accountBalance").text(web3.fromWei(balance, "ether") + " TKK");
                  }
            });
            }
      });
      },

      reloadZombies: function () {
            
      },

      buyTKK: function () {
            // get information from the modal
            var _zombie_name = $('#zombie_name').val();
        
            // if the name was not provided
            if (_zombie_name.trim() == '') {
                    // we cannot create a zombie
                    return false;
            }
        
            // get the instance of the ZombieOwnership contract
            App.contracts.TikkunToken.deployed().then(function (instance) {
                    // call the createRandomZombie function, 
                    // passing the zombie name and the transaction parameters
                    instance.transfer(_zombie_name, 5, {
                        from: App.account,
                        gas: 500000
                    });
            // log the error if there is one
            }).then(function () {
        
            }).catch(function (error) {
                    console.log(error);
            });
        },
};





$(function() {
     $(window).load(function() {
          App.init();
     });
});
