const APRWithPoolOracle = artifacts.require("APRWithPoolOracle")
module.exports = async function(deployer) {
  await deployer.deploy(APRWithPoolOracle);
};