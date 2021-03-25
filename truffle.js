module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    local: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*'    
    },
    staging: {
      host: '13.58.147.177',
      port: 8555,
      network_id: '*'
    },
    production: {
      host: '',
      port: 8555,
      network_id: '*',
      gasPrice: 175000000000 //175 GWei
    }
  },
  mocha: {
    useColors: true
  },
  compilers: {
    solc: {
      version: '0.7.3', // A version or constraint - Ex. "^0.5.0"
                         // Can also be set to "native" to use a native solc
      settings: {
        optimizer: {
          enabled: true
        }
      }
    }
  }
};
