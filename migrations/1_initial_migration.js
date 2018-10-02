var Migrations = artifacts.require("./Migrations.sol")
var SatToken = artifacts.require("./SatToken.sol")

var SplytManager = artifacts.require("./SplytManager.sol")

var OrderManager = artifacts.require("./OrderManager.sol")
var OrderData = artifacts.require("./OrderData.sol")

var AssetManager = artifacts.require("./AssetManager.sol")
var AssetData = artifacts.require("./AssetData.sol")

var ArbitrationManager = artifacts.require("./ArbitrationManager.sol")
var ArbitrationData = artifacts.require("./ArbitrationData.sol")

var ReputationManager = artifacts.require("./ReputationManager.sol")
var ReputationData = artifacts.require("./ReputationData.sol")

var ManagerTracker = artifacts.require("./ManagerTracker.sol")

var Stake = artifacts.require("./Stake.sol")
var chalk = require('chalk')

module.exports = function(deployer, network, accounts) {

  var name = "SPLYT"
  var desc = "Global inventory on the blockchain"
  var ver  = 3
  var walletConfig = {}

  if(network === 'testnet') {
    walletConfig = { from: "0xf606a61e2fbc2db9b0b74f26c45469509dfb33ac" }
  } else {                                                      
    walletConfig = { from: accounts[0] }
  }

  console.log('using main wallet: ')
  console.log(walletConfig)


  deployer.deploy(Migrations, walletConfig)

  deployer.deploy(SatToken, name, desc, ver, walletConfig)
  .then(async function(satToken) {
    console.log('Sat Token address: ', SatToken.address)

    //give accounts 1 default tokens
    await satToken.initUser(accounts[0], walletConfig)

    var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, 100, walletConfig)
    console.log('Stake address: ', stake.address)


    var splytManager = await deployer.deploy(SplytManager, SatToken.address, stake.address, walletConfig)
    console.log('Splyt Manager address: ', splytManager.address)

    var managerTracker = await deployer.deploy(ManagerTracker, splytManager.address, walletConfig)
    console.log('ManagerTracker address: ', managerTracker.address)
    splytManager.setManagerTracker(managerTracker.address, walletConfig)

    var assetManager = await deployer.deploy(AssetManager, splytManager.address, walletConfig)
    console.log('AssetManager address: ', assetManager.address)
    splytManager.setAssetManager(assetManager.address, walletConfig)

    var orderManager = await deployer.deploy(OrderManager, splytManager.address, walletConfig)
    console.log('OrderManager address: ', orderManager.address)
    splytManager.setOrderManager(orderManager.address, walletConfig)

    var arbitrationManager = await deployer.deploy(ArbitrationManager, splytManager.address, walletConfig)
    console.log('ArbitrationManager address: ', arbitrationManager.address)
    splytManager.setArbitrationManager(arbitrationManager.address, walletConfig)
    
    var reputationManager = await deployer.deploy(ReputationManager, splytManager.address, walletConfig)
    console.log('ReputationManager address: ', reputationManager.address)
    splytManager.setReputationManager(reputationManager.address, walletConfig)

  });
  
};
