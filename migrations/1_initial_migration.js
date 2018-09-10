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

  if(network === 'testnet')
    walletConfig = { from: "0xd9e5e4bde24faa2b277ab2be78c95b9ae24259a8" }
                                                                                   
   else
    walletConfig = { from: accounts[0] }

  deployer.deploy(Migrations, walletConfig)

  deployer.deploy(SatToken, name, desc, ver, walletConfig)
  .then(async function(satToken) {
    console.log('Sat Token address: ', SatToken.address)

    //give accounts 1 default tokens
    satToken.initUser(accounts[0])

    var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, 100, walletConfig)
    console.log('Stake address: ', stake.address)


    var splytManager = await deployer.deploy(SplytManager, SatToken.address, stake.address, walletConfig)
    console.log('Splyt Manager address: ', splytManager.address)

    var managerTracker = await deployer.deploy(ManagerTracker, splytManager.address, walletConfig)
    console.log('ManagerTracker address: ', managerTracker.address)
    await splytManager.setManagerTracker(managerTracker.address)

    var assetManager = await deployer.deploy(AssetManager, splytManager.address, walletConfig)
    console.log('AssetManager address: ', assetManager.address)
    await splytManager.setAssetManager(assetManager.address)

    var orderManager = await deployer.deploy(OrderManager, splytManager.address, walletConfig)
    console.log('OrderManager address: ', orderManager.address)
    await splytManager.setOrderManager(orderManager.address)

    var arbitrationManager = await deployer.deploy(ArbitrationManager, splytManager.address, walletConfig)
    console.log('ArbitrationManager address: ', arbitrationManager.address)
    await splytManager.setArbitrationManager(arbitrationManager.address)
    
    var reputationManager = await deployer.deploy(ReputationManager, splytManager.address, walletConfig)
    console.log('ReputationManager address: ', reputationManager.address)
    await splytManager.setReputationManager(reputationManager.address)

  });
  
};
