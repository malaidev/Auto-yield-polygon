const EarnAPRWithPool = artifacts.require("EarnAPRWithPool")
module.exports = async function(deployer) {
  await deployer.deploy(EarnAPRWithPool);
};