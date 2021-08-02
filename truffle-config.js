var HDWalletProvider = require("truffle-hdwallet-provider");
require('dotenv').config();
/**
 * Use this file to configure your truffle project. It's seeded with some
 * common settings for different networks and features like migrations,
 * compilation and testing. Uncomment the ones you need or modify
 * them to suit your project as necessary.
 *
 * More information about configuration can be found at:
 *
 * truffleframework.com/docs/advanced/configuration
 *
 * To deploy via Infura you'll need a wallet provider (like truffle-hdwallet-provider)
 * to sign your transactions before they're sent to a remote public node. Infura accounts
 * are available for free at: infura.io/register.
 *
 * You'll also need a mnemonic - the twelve word phrase the wallet uses to generate
 * public/private key pairs. If you're publishing your code to GitHub make sure you load this
 * phrase from a file you've .gitignored so it doesn't accidentally become public.
 *
 */

// const HDWalletProvider = require('truffle-hdwallet-provider');
// const infuraKey = "fj4jll3k.....";
//
// const fs = require('fs');
// const mnemonic = fs.readFileSync(".secret").toString().trim();

module.exports = {
  /**
   * Networks define how you connect to your ethereum client and let you set the
   * defaults web3 uses to send transactions. If you don't specify one truffle
   * will spin up a development blockchain for you on port 9545 when you
   * run `develop` or `test`. You can ask a truffle command to use a specific
   * network from the command line, e.g
   *
   * $ truffle test --network <network-name>
   */
  contracts_build_directory: "./build",
  networks: {
    development: {
      host: "127.0.0.1",     // Localhost (default: none)
      port: 7545,            // Standard Ethereum port (default: none)
      network_id: "*",       // Any network (default: none)
    },
    mumbai: {
      provider: () => new HDWalletProvider(process.env.PK, `https://rpc-mumbai.matic.today`),
      network_id: 80001,
      gasPrice: 10000000000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    matic: {
      provider: () => new HDWalletProvider(process.env.PK, `https://rpc-mainnet.matic.network`),
      network_id: 137,
      gasPrice: 1000000000,
      confirmations: 2,
      timeoutBlocks: 200,
      skipDryRun: true
    },
    mainnet: {
      provider: () => new HDWalletProvider(process.env.PK, "https://mainnet.infura.io/v3/" + process.env.INFURA_API_KEY),
      port: 8545,
      network_id: "1",
      gas: 6000000,
      gasPrice: 4000000000
    },
    rinkeby: {
      provider: () => new HDWalletProvider(process.env.PK, "https://rinkeby.infura.io/v3/" + process.env.INFURA_API_KEY),
      port: 8545,
      network_id: "4",
      gas: 6000000,
      gasPrice: 40000000000
    },
    ropsten: {
      provider: () => new HDWalletProvider(process.env.PK, "https://ropsten.infura.io/v3/" + process.env.INFURA_API_KEY),
      port: 8545,
      network_id: "3",
      gas: 6000000,
      gasPrice: 40000000000
    },
    rinkebyLocal: {
      host: "localhost",
      port: 8545,
      network_id: "4", // Rinkeby network id
      from:"0x1e09a22f24d8fd302b2028a688658e9b29551969"
    },
    coverage: {
      host: "localhost",
      network_id: "*",
      port: 8545,         // <-- If you change this, also set the port option in .solcover.js.
      gas: 0xfffffffffff, // <-- Use this high gas value
      gasPrice: 0x01      // <-- Use this low gas price
    },
  },

  // Set default mocha options here, use special reporters etc.
  mocha: {
    timeout: 300000
  },

  // Configure your compilers
  compilers: {
    solc: {
      // version: "0.5.1",    // Fetch exact version from solc-bin (default: truffle's version)
      // docker: true,        // Use "0.5.1" you've installed locally with docker (default: false)
      settings: {          // See the solidity docs for advice about optimization and evmVersion
       optimizer: {
         enabled: false,
         runs: 200
       },
      //  evmVersion: "byzantium"
      }
    }
  }
}
