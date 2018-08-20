var WithDrawal = artifacts.require("./WithDrawal.sol");

contract ("WithDrawal",function(accounts){
    //var balances[msg.sender] = 100;

    it("Should mint new tokens",function(){
        return WithDrawal.deployed().then(function(instance){
            instance.mint(accounts[0],6000,{'from': accounts[0]});
            return instance.balances(accounts[0]);            
        }).then(function(balance){
            assert.equal(balance.toNumber(),6000,"Balance is not equal to 3000")
        })

    });
    it("Should withdraw funds",function(){
        return WithDrawal.deployed().then(function(instance){
            WithDrawalInstance = instance;
            return WithDrawalInstance.withDrawals(accounts[1],4000,{from : accounts[0]});
            
        }).then(function(){
            return WithDrawalInstance.balances(accounts[0]);
        }).then(function(balance){
            assert.equal(balance.toNumber(),2000,"2000 wasn't in account 0");
        }).then(function(){
            return WithDrawalInstance.balances(accounts[1]);
        }).then(function(balance){
            assert.equal(balance.toNumber(),4000,"4000 wasn't in account 1");
        
        });

    });
    it("Should fail withdraw funds",function(){
        return WithDrawal.deployed().then(function(instance){
            WithDrawalInstance = instance;
            return WithDrawalInstance.withDrawals(accounts[1],1001,{from : accounts[0]});
        });

    });    
})