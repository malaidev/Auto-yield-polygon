const XMATIC = artifacts.require("XMATIC")
module.exports = async function(deployer) {
  await deployer.deploy(XMATIC);
};