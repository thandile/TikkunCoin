var TikkunToken = artifacts.require("./TikkunToken.sol");
var SafeMath = artifacts.require("./TikkunToken.sol");


contract('TikkunToken', function(accounts) {
    it("should return total token supply", function() {
      var token;
      return TikkunToken.deployed().then(function(instance){
       token = instance;
       return token.totalSupply();
      }).then(function(result){
       assert.equal(result.toNumber(), 0, 'total supply is wrong');
      })
    });

    it("should return the balance of token owner", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        return token.balanceOf(accounts[0]);
        }).then(function(result){
        assert.equal(result.toNumber(), 0, 'balance is wrong');
        })
    });

    it("should increase totalSupply", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        token.increaseSupply(1000000, accounts[0], {'from': accounts[0]});
        return token.balanceOf(accounts[0]);
        }).then(function(result){
        assert.equal(result.toNumber(), 1000000, 'accounts[0] balance is wrong');
      })
    });

    it("should transfer right token", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        return token.transfer(accounts[1], 500000, {'from': accounts[0]});
        }).then(function(){
        return token.balanceOf(accounts[0]);
        }).then(function(result){
        assert.equal(result.toNumber(), 500000, 'accounts[0] balance is wrong');
        return token.balanceOf(accounts[1]);
        }).then(function(result){
        assert.equal(result.toNumber(), 500000, 'accounts[1] balance is wrong');
        })
    });
    it("should give accounts[1] authority to spend account[0]'s token", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
        token = instance;
        return token.approve(accounts[1], 200000);
        }).then(function(){
        return token.allowance(accounts[0], accounts[1]);
        }).then(function(result){
        assert.equal(result.toNumber(), 200000, 'allowance is wrong');
        return token.transferFrom(accounts[0], accounts[2], 200000, {from: accounts[1]});
        }).then(function(){
        return token.balanceOf(accounts[0]);
        }).then(function(result){
        assert.equal(result.toNumber(), 300000, 'accounts[0] balance is wrong');
        return token.balanceOf(accounts[1]);
        }).then(function(result){
        assert.equal(result.toNumber(), 500000, 'accounts[1] balance is wrong');
        return token.balanceOf(accounts[2]);
        }).then(function(result){
        assert.equal(result.toNumber(), 200000, 'accounts[2] balance is wrong');
        })
    });

    it("should show the transfer event", function() {
        var token;
        return TikkunToken.deployed().then(function(instance){
          token = instance;
          return token.transfer(accounts[1], 100000);
        }).then(function(result){
          console.log(result.logs[0].event)
        })
      });
});