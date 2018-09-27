var Migrations = artifacts.require("./Migrations.sol")
var SatToken = artifacts.require("./SatToken.sol")
var SplytTracker = artifacts.require("./SplytTracker.sol")
var ArbitrationFactory = artifacts.require("./ArbitrationFactory.sol")
var Stake = artifacts.require("./Stake.sol")
var chalk = require('chalk')

module.exports = (deployer, network, accounts) => {

  var name = "SPLYT"
  var desc = "Global inventory on the blockchain"
  var ver  = 3
  var walletConfig = {}

  walletConfig.from = network === 'testnet' ? "0xd9e5e4bde24faa2b277ab2be78c95b9ae24259a8" : accounts[0]

  deployer.deploy(Migrations, walletConfig)

  deployer.deploy(SatToken, name, desc, ver, walletConfig)
  .then(async ()=> {
    console.log(chalk.green('Sat Token address: ', SatToken.address))
    var arbitrationFactory = await deployer.deploy(ArbitrationFactory, walletConfig)
    console.log('Arbitration Factory address: ', arbitrationFactory.address)
    var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, 100, walletConfig)
    console.log('Stake address: ', stake.address)
    var deployed = await deployer.deploy(SplytTracker, ver, name, SatToken.address, arbitrationFactory.address, stake.address, walletConfig)
    console.log(chalk.green('Splyt Tracker address: ', SplytTracker.address))
  });
};
