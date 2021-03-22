var Migrations = artifacts.require("./Migrations.sol")
var ERC20 = artifacts.require("./Token/ERC20.sol")
var Vesting = artifacts.require("./Token/Vesting.sol")

var Chalk = require('chalk')
var Fs = require('fs')
var Path = require('path')
var CsvToJson = require('csvtojson')

module.exports = function(deployer, network, accounts) {

  const name = "Splyt SHOPX tokens"
  const symbol = "SHOPX"

  let walletConfig = {}

  if(network === 'ropsten') {
    walletConfig = { from: "0xf606a61e2fbc2db9b0b74f26c45469509dfb33ac" }
  } else {                                                      
    walletConfig = { from: accounts[0] }
  }

  console.log(Chalk.green('Deploy wallet address: ' + walletConfig.from))

  const logFilePath = InitLogFile()
  // console.log('starting to load csv')
  // var csvDistribution = await LoadCsv()
  // console.log('loaded csv data')
  deployer.deploy(Migrations, walletConfig)

  deployer.deploy(ERC20, name, symbol, walletConfig)
  .then(erc20 => {
  
    Log('ERC20 Deployed')
    Log('TxHash: ' + erc20.transactionHash)
    Log('ContractAddress: ' + erc20.address)

    LoadCsv(csvDistribution => {
      console.log(csvDistribution);
    })

  })

  function InitLogFile() {

    const folderPath = Path.resolve('./logs')
    if (!Fs.existsSync(folderPath))
      fs.mkdirSync(folderPath, {recursive: true})
    const now = new Date()
    const filePath = folderPath + '/' + now.getUTCFullYear() + '-' + now.getUTCMonth() + '-' + now.getUTCDate() + '_' + network
    Fs.appendFileSync(filePath, '\n\n' + now.getUTCHours() + ':' + now.getUTCMinutes() + '-------------------------\n');
    return filePath
  }

  function Log(message) {
    if(message.includes("err")) {
      console.log(Chalk.red(message))
    } else {
      console.log(Chalk.green(message))
    }
    Fs.appendFileSync(logFilePath, message + '\n');
  }

  function LoadCsv(cb) {
    const filePath = Path.resolve('./[Mock] Token Distribution List - Sheet1.csv')
    CsvToJson().fromFile(filePath)
    .then(distributionJson => {
      cb(distributionJson)
    })
  }

}
