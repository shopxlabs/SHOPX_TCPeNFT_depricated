module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    localhost: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*'    
    },
    ropsten: {
      host: '13.58.147.177',
      port: 8555,
      network_id: '*'
    }
  },
  mocha: {
    useColors: true
  },
  compilers: {
    solc: {
      version: '^0.4.24', // A version or constraint - Ex. "^0.5.0"
                         // Can also be set to "native" to use a native solc
      settings: {
        optimizer: {
          enabled: true
        }
      }
    }
  }
};
