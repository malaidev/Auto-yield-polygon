const XAAVE = artifacts.require("XAAVE")
module.exports = async function(deployer) {
  await deployer.deploy(XAAVE);
};