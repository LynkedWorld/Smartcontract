
var LYNKToken = artifacts.require("./LYNKToken.sol");

module.exports = function(deployer) {
  deployer.deploy(LYNKToken);
};