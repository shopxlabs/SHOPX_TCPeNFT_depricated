var Migrations = artifacts.require("./Migrations.sol")
var SatToken = artifacts.require("./SatToken.sol")
var SplytManager = artifacts.require("./SplytManager.sol")
var OrderManager = artifacts.require("./OrderManager.sol")
var OrderData = artifacts.require("./OrderData.sol")
var Stake = artifacts.require("./Stake.sol")
var chalk = require('chalk')

module.exports = function(deployer, network, accounts) {

  var name = "SPLYT"
  var desc = "Global inventory on the blockchain"
  var ver  = 3
  var walletConfig = {}

  if(network === 'testnet')
    walletConfig = { from: "0xd9e5e4bde24faa2b277ab2be78c95b9ae24259a8" }
   else
    walletConfig = { from: accounts[0] }

  deployer.deploy(Migrations, walletConfig)

  // deployer.deploy(SatToken, name, desc, ver, walletConfig)
  // .then(async function() {
  //   console.log('Sat Token address: ', SatToken.address)
  //   var arbitrationFactory = await deployer.deploy(ArbitrationFactory, walletConfig)
  //   console.log('Arbitration Factory address: ', arbitrationFactory.address)
  //   var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, 100, walletConfig)
  //   console.log('Stake address: ', stake.address)
  //   var deployed = await deployer.deploy(SplytTracker, ver, name, SatToken.address, arbitrationFactory.address, stake.address, walletConfig)
  //   console.log('Splyt Tracker address: ', SplytTracker.address)
  // });

  deployer.deploy(SatToken, name, desc, ver, walletConfig)
  .then(async function() {
    console.log('Sat Token address: ', SatToken.address)

    var orderData = await deployer.deploy(OrderData, walletConfig)
    console.log('OrderData address: ', arbitrationFactory.address)

    var orderManager = await deployer.deploy(OrderManager, walletConfig)
    console.log('OrderManager address: ', orderManager.address)
    
    var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, 100, walletConfig)
    console.log('Stake address: ', stake.address)
    
    var deployed = await deployer.deploy(SplytManager, walletConfig)
    console.log('Splyt Manager address: ', SplytManager.address)
  });
  
};
