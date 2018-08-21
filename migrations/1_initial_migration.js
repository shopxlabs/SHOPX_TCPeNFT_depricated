var Migrations = artifacts.require("./Migrations.sol")
var SatToken = artifacts.require("./SatToken.sol")

var SplytManager = artifacts.require("./SplytManager.sol")

var OrderManager = artifacts.require("./OrderManager.sol")
var OrderData = artifacts.require("./OrderData.sol")

var AssetManager = artifacts.require("./AssetManager.sol")
var AssetData = artifacts.require("./AssetData.sol")

var ArbitrationManager = artifacts.require("./ArbitrationManager.sol")
var ArbitrationData = artifacts.require("./ArbitrationData.sol")

var ManagerHistory = artifacts.require("./ManagerHistory.sol")

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

    var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, 100, walletConfig)
    console.log('Stake address: ', stake.address)

    var managerHistory = await deployer.deploy(ManagerHistory, walletConfig)
    console.log('Manager History address: ', managerHistory.address)

    var splytManager = await deployer.deploy(SplytManager, SatToken.address, stake.address, managerHistory.address, walletConfig)
    console.log('Splyt Manager address: ', splytManager.address)

    //add splyt manager
    managerHistory.addManager(splytManager.address, walletConfig);

    var assetManager = await deployer.deploy(AssetManager, splytManager.address, walletConfig)
    console.log('AssetManager address: ', assetManager.address)
    await splytManager.setAssetManager(assetManager.address)

    var orderManager = await deployer.deploy(OrderManager, splytManager.address, walletConfig)
    console.log('OrderManager address: ', orderManager.address)
    await splytManager.setOrderManager(orderManager.address)

    var arbitrationManager = await deployer.deploy(ArbitrationManager, splytManager.address, walletConfig)
    console.log('ArbitrationManager address: ', arbitrationManager.address)
    await splytManager.setArbitrationManager(arbitrationManager.address)

  });
  
};
