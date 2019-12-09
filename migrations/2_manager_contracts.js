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

// This migration manages/update/changes existing deployed contracts 
module.exports = function(deployer, network, accounts) {
  

}