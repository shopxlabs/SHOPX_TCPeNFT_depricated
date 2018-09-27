//const shell = require('shelljs')
const SplytTracker = artifacts.require('SplytTracker')
const SatToken = artifacts.require('SatToken')
const shelljs = require('../lib/shelljs-nodecli')

module.exports = (deployer, network, accounts) => {

  // console.log(deployer)
  // console.log(artifacts)
  // console.log(SatToken.abi)
  let satTokenAbi = SatToken.abi
  let satTokenAddr = SatToken.address
  let splytTrackerAbi = SplytTracker.abi
  let splytTrackerAddr = SplytTracker.address

  var arr = []
  arr.push(satTokenAddr)
  //arr.push(JSON.stringify(satTokenAbi))
  arr.push(splytTrackerAddr)
  //arr.push(JSON.stringify(splytTrackerAbi))
  // console.log(arr)
  // console.log('hello', satTokenAddr, splytTrackerAddr)
  if(network !== 'testnet') {
    shelljs.exec("./copy_to_backend.sh", arr, (code, stdout, stderr) => {
      
    })
  }
   
};


