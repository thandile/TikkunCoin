var TikkunToken = artifacts.require("./TikkunToken.sol");
var SafeMath = artifacts.require("./SafeMath.sol");
var Owned = artifacts.require("./Owned.sol");
var ERC621Interface = artifacts.require("./ERC621Interface.sol");

module.exports = function(deployer) {
  deployer.deploy(TikkunToken);
  deployer.deploy(SafeMath);
  deployer.deploy(Owned);
  deployer.deploy(ERC621Interface);
};
