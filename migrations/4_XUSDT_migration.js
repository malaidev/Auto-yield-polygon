const XUSDT = artifacts.require("XUSDT")
module.exports = async function(deployer) {
  await deployer.deploy(XUSDT);
};