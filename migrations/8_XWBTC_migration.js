const XWBTC = artifacts.require("XWBTC")
module.exports = async function(deployer) {
  await deployer.deploy(XWBTC);
};