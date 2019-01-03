module.exports = {
  // See <http://truffleframework.com/docs/advanced/configuration>
  // to customize your Truffle configuration!
  networks: {
    development: {
      host: '127.0.0.1',
      port: 8545,
      network_id: '*'    
    },
    testnet: {
      host: '13.58.147.177',
      port: 8555,
      network_id: '*'
    }
  },
  mocha: {
    useColors: true
  },
  solc: {
    optimizer: {
      enabled: true
    }
  }
};
