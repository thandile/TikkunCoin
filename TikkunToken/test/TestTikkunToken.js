var TikkunToken = artifacts.require("./TikkunToken.sol");
var SafeMath = artifacts.require("./TikkunToken.sol");


contract('TikkunToken', function(accounts) {
    it("should return total token supply", function() {
      var token;
      return TikkunToken.deployed().then(function(instance){
       token = instance;
       return token.totalSupply.call();
      }).then(function(result){
       assert.equal(result.toNumber(), 1000000, 'total supply is wrong');
      })
    });
  });

contract('TikkunToken', function(accounts) {
    it("should return the balance of token owner", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        return token.balanceOf.call(accounts[0]);
        }).then(function(result){
        assert.equal(result.toNumber(), 0, 'balance is wrong');
        })
    });
});


contract('TikkunToken', function(accounts) {
    it("should increase totalSupply", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        return token.increaseSupply.call(1000000);
        }).then(function(result){
        return token.totalSupply.call();
      }).then(function(result){
       assert.equal(result.toNumber(), 2000000, 'total supply is wrong');
      })
    });
});

contract('TikkunToken', function(accounts) {    
    it("should transfer right token", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        return token.transfer(accounts[1], 5);
        }).then(function(){
        return token.balanceOf.call(accounts[0]);
        }).then(function(result){
        assert.equal(result.toNumber(), 500000, 'accounts[0] balance is wrong');
        return token.balanceOf.call(accounts[1]);
        }).then(function(result){
        assert.equal(result.toNumber(), 5, 'accounts[1] balance is wrong');
        })
    });
});