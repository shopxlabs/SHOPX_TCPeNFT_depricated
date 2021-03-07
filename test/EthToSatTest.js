const Asset = artifacts.require("../Protocol/Asset.sol")
const SplytManager = artifacts.require("../Protocol/SplytManager.sol")
const AssetManager = artifacts.require("../Protocol/AssetManager.sol")
const ShopxToken = artifacts.require("../Token/ShopxToken.sol")
const SplytPriceOracle = artifacts.require("../Token/SplytPriceOracle.sol")
const chalk = require('chalk')


contract('ETH To SHOPX unit tests:', function(accounts) {

  let assetAddress
  let assetInstance
  let assetManagerAddress
  let assetManagerInstance
  let splytManagerInstance
  let splytPriceOracleInstance

  const assetCost = 1000
  let shopxTokenInstance
  const defaultTokenAmount = 20500

  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 1, _seller = accounts[1], _title = "Asset with ether deposit instead of SHOPXs",
      _totalCost = 1000, _expirationDate = 10001556712588, _mpAddress = accounts[2], _mpAmount = 2, _inventory = 1){
        console.log('how is it going')
        splytManagerInstance = await SplytManager.deployed()
    assetManagerInstance = await AssetManager.deployed()
    splytPriceOracleInstance = await SplytPriceOracleInstance.deployed()
    
    var a = await splytPriceOracleInstance.getEthUsd()
    await assetManagerInstance.ethToShopx(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventory)
    assetAddress = await assetManagerInstance.getAddressById(_assetId)
    assetInstance = await Asset.at(assetAddress)
  }

  // This function gets ran before every test cases in this file.
  beforeEach('Giving out SHOPX tokens to all wallets in system. ', async function() {
    // reset all account's token balance to 20500.0000 SHOPX tokens before running each test
    shopxTokenInstance = await ShopxToken.deployed()
    accounts.forEach(async function(acc) {
      await shopxTokenInstance.initUser(acc, 205000000)
    })
  })

  it('should be status ACTIVE after deploying a new asset contract.', async function() {
    await create_asset("0x31f2ae92057a7123ef0e490a", 1, accounts[1], "MyTitle", 1000, 10001556712588, accounts[2], 2, 1)
    var status = await assetInstance.status()
    console.log('status of asset just deployed', status)
    assert.equal(status, 1, 'New asset contract is not in ACTIVE(1) status!')
  })

  // it('should be able to sucessfully deploy asset contract from ETH To SHOPX function.', async function() {
  //   assert.equal(1,1,'success')
  // })


  async function sleep(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds))
  }
})