var TikkunToken = artifacts.require("./TikkunToken.sol");

module.exports = function(deployer) {
  deployer.deploy(TikkunToken);
};
