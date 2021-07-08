const xUSDT = artifacts.require("xUSDT");
const Token = artifacts.require("TetherToken")
module.exports = async function(deployer) {
  await deployer.deploy(Token, 1000, "TetherToken", "TT", 18);
  // const token = await Token.deployed()
  
  // console.log(token.address)
  // res = await res.deployed()
  // console.log(res)
  // let token = await Token.deployed()
  // let a = '0xbc7fBc899c147D3485f05Bf67931D20CAc71D516'
  // await deployer.deploy(xUSDT, token.address);
  await deployer.deploy(xUSDT);
};



// const TokenBsc = artifacts.require('TokenBsc.sol')
// const BridgeBsc = artifacts.require('BridgeBsc.sol')

// module.exports = async function (deployer, network, accounts) {
//   // if(network === 'bscTestnet') {
//     await deployer.deploy(TokenBsc)
//     const tokenBsc = await TokenBsc.deployed()
//     await tokenBsc.updateAdmin(accounts[0])
//     const token_admin = await tokenBsc.getOwner()
//     await deployer.deploy(BridgeBsc, tokenBsc.address)
//     const bridgeBsc = await BridgeBsc.deployed()
//   // }
// };