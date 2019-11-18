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
var SplytPriceOracle = artifacts.require("./SplytPriceOracle.sol")
var chalk = require('chalk')
var fetch = require('fetch').fetchUrl

module.exports = function(deployer, network, accounts) {

  const name = "SPLYT"
  const desc = "Global inventory on the blockchain"
  const ver  = 3

  let walletConfig = {}

  if(network === 'ropsten') {
    walletConfig = { from: "0xf606a61e2fbc2db9b0b74f26c45469509dfb33ac" }
  } else {                                                      
    walletConfig = { from: accounts[0] }
  }

  console.log('using main wallet: ')
  console.log(walletConfig)

  fetchCurrentEtherPrice()
  deployer.deploy(Migrations, walletConfig)

  deployer.deploy(SatToken, name, desc, ver, walletConfig)
  .then(async function(satToken) {
    console.log('Sat Token address: ', SatToken.address)

    //give accounts 1 default tokens
    await satToken.initUser(accounts[0], 205000000, walletConfig)
    var stake = await deployer.deploy(Stake, 10000000000000, 2000000000, walletConfig)
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

    var splytPriceOracle = await deployer.deploy(SplytPriceOracle, walletConfig)
    assetManager.setOracleAddress(splytPriceOracle.address, walletConfig)
    console.log('Splyt Price Oracle address: ', splytPriceOracle.address)
    await splytPriceOracle.setEthUsd(parseInt(etherPrice), walletConfig)
    var a = await splytPriceOracle.getEthUsd(walletConfig)
  })
  
  function fetchCurrentEtherPrice() {
    fetch('https://pro-api.coinmarketcap.com/v1/cryptocurrency/quotes/latest?id=1027', {
      method: 'GET',
      headers: {'X-CMC_PRO_API_KEY':'9ee3f9be-fc7a-4b0f-8843-df2e01195d25'}
    }, (err, meta, body) => {
      // returning dollar amount moved 4 decimal places so intead od $86.5920xx... it'll be $865920.xx...
      etherPrice = JSON.parse(body.toString()).data[1027].quote.USD.price * 10000
    })
  }
}
