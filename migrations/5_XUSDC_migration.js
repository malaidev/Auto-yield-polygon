const XUSDC = artifacts.require("XUSDC")
module.exports = async function(deployer) {
  await deployer.deploy(XUSDC);
};