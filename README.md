# splytprotocol
Ethereum contracts for split protocol

### Branch specific info:
 - Derived from branch **ver2.1**

### Setup:
 - `git clone https://github.com/splytcore/splytprotocol.git`
 - `npm install truffle -g`
 - `npm install testrpc -g`

### Run:
 - In terminal `testrpc`. Leave terminal tab open
 - In terminal `cd path/to/project`
 - `truffle compile`. Will compile all contracts
 - `truffle migrate --reset`. Will deploy all contracts to testrpc network
 - `truffle test ./test/[fileName].js`. Will test all functions in that file  
 
 ### Deploy contracts to Ropsten:  
 - In terminal type  `truffle migrate --network testnet  --reset`.
 - Copy splytManagerAddress and update in /splytcoreui/conifg/env/dev.js  
 
 **Things to look out for: 
 
  - Truffle doesn't like OSX folder `.DS_Store` so keep an eye for it in `/build/contracts` folder as well as anywhere else in the project. Remove that folder and run the instructions again if issues arise.
  - If you still have problems delete everything under `/build/contracts` and re-run the steps above.
  - If you get this error `Error: sender doesn't have enough funds to send tx` restart testrpc (you ran out of test ether)
  - Or else the problem is with your code. Good luck.
 
 
### Schema in Ver 0.2.0. 
Contracts are modular meaning they can be exchanged for updated contracts and disregard the old EXCEPT the Data contracts.  

** Initial Deploy Contracts Schema.    
Remeber only the wallet used to deploy these contracts are the 'owner'. The role gives him/her rights to swap addresses.  
-  Deploy the SatToken contract and keep the address in hand.    
-  Deploy the Stake contract and keep the address in hand.   
-  Deploy the SplytManager contract and pass the SatToken and Stake addresses as the constructors.   
-  Deploy the manager contracts with the SplytManager address as the constructor parameter.  
-  Using the SplytManager contract, call each functions to set the manager i.e. 'setAssetManager(_newAddress)'.   
** Note: Only manager contracts are authorized to write to the data contracts.     


### Updating manager contracts.  
-  All contracts except the data contracts can be replaced. Thus updated versions of the manager contracts can be binded with the existing data contracts.  
-  After updating any of the manager contracts, you can change ownership of the data contract from the old manager to the new manager contracts in the following steps:  
1.  Deploy updated manager contract.  After being mined, save the new address. Do it for each manager contract you are updating. 
2.  Using the new mangager contract call function 'setDataContract(_dataAddress)'. This will be bind the old existing data contract to the new manager contract.  
3.  Using the old manager contract you are replacing, call function 'transferOwnership(_newAddress)' with the new manager address. This proposes new ownership.  
4.  Using the new mangager contract call function 'acceptOwnership()'.  Now the updated manager is the owner of the data contract.  
5.  Using splytManager update the manager contracts, i.e. 'setAssetManager(_newAddress)'.  



### Tests   
-  Only the initial test for managers were created.    
-  The old test files have been left alone.  


### Changelogs
2019-12-08: Added file export to addresses to be used in phase 2 of contract migrations. Upgraded compiler version to 0.5.13
