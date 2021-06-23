const tEther = artifacts.require("TetherToken");

module.exports = function(deployer) {
  deployer.deploy(tEther, 1000);
};
