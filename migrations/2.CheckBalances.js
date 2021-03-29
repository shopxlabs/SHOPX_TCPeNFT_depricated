var ERC20 = artifacts.require("./Token/ERC20.sol")
var Vesting = artifacts.require("./Token/Vesting.sol")

var Chalk = require('chalk')
var Fs = require('fs')
var Path = require('path')
var CsvToJson = require('csvtojson')
var fetch = require('fetch').fetchUrl
// var bigInt = require('bit-ingeger')


module.exports = async function(deployer, network, accounts) {

//   deployer.networks.local.gasPrice = fetchGasPrice('normal')
//   console.log(deployer.networks.local.gasPrice)


  const name = "Splyt SHOPX tokens"
  const symbol = "SHOPX"

  let walletConfig = {}

  if(network === 'staging') {
    walletConfig = { from: "0xd9e5e4bde24faa2b277ab2be78c95b9ae24259a8" }
  } else {                                                      
    walletConfig = { from: accounts[0] }
  }

  console.log(Chalk.green('Deploy wallet address: ' + walletConfig.from))

  const aMonth = 2629743
  const logFilePath = InitLogFile()

  var ercAddress = '0xb0085b9Bc3e77F4082128Bb0b80C0D48541fca9B'
  var vestingAddress = '0xbe694f2205488a6F117A3d29e2227D735f3E87ee'
  var beneficaryAddress = '0x24eD05c234aa2CaF4503D737348e580f18479316'

  var erc20 = await ERC20.at(ercAddress)
  await erc20.balanceOf(vestingAddress, walletConfig)
  .then(vestingBalance => {
      console.log('Vesting tokens: ' + BigInt(vestingBalance))
  })

  await erc20.balanceOf(beneficaryAddress, walletConfig)
  .then(vestingBalance => {
      console.log('Beneficiary tokens: ' + BigInt(vestingBalance))
  })

  var vesting = await Vesting.at(vestingAddress)

  var released = await vesting.release(erc20.address, walletConfig)
  
  await erc20.balanceOf(vestingAddress, walletConfig)
  .then(vestingBalance => {
      console.log('Vesting tokens: ' + BigInt(vestingBalance))
  })

  await erc20.balanceOf(beneficaryAddress, walletConfig)
  .then(vestingBalance => {
      console.log('Beneficiary tokens: ' + BigInt(vestingBalance))
  })
  
  function InitLogFile() {

    const folderPath = Path.resolve('./logs')
    if (!Fs.existsSync(folderPath))
      fs.mkdirSync(folderPath, {recursive: true})
    const now = new Date()
    const filePath = folderPath + '/' + now.getUTCFullYear() + ':' + now.getUTCMonth() + ':' + now.getUTCDate() + '_' + network
    Fs.appendFileSync(filePath, '\n\n' + LogPrefix() + '-------------------------\n');
    return filePath
  }

  function Log(message) {
    if(message.includes("err")) {
      console.log(Chalk.red(LogPrefix() + ' ' + message))
    } else {
      console.log(Chalk.green(LogPrefix() + ' ' + message))
    }
    Fs.appendFileSync(logFilePath, LogPrefix() + ' ' + message + '\n');
  }

  function LogPrefix() {
    const now = new Date()
    return now.getUTCHours() + ':' + now.getUTCMinutes() + ':' + now.getUTCSeconds()
  }

  function fetchGasPrice(speed) {
    fetch('https://api.etherscan.io/api?module=gastracker&action=gasoracle&apikey=HB19QTI959UAFKGDZ6NPXQJVHCGU9REU1K', {
      method: 'GET',
      headers: {}
    }, (err, meta, body) => {
      // returning dollar amount moved 4 decimal places so intead of $86.5920xx... it'll be $865920.xx...
      // etherPrice = JSON.parse(body.toString()).data[1027].quote.USD.price * 10000

      var response = JSON.parse(body.toString())
      console.log(response.result.SafeGasPrice)
      return response.result.SafeGasPrice
    })
  }
}
