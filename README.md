# splytprotocol
Ethereum contracts for split protocol

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
 
 
 **Things to look out for: 
 
  - Truffle doesn't like OSX folder `.DS_Store` so keep an eye for it in `/build/contracts` folder as well as anywhere else in the project. Remove that folder and run the instructions again if issues arise.
  - If you still have problems delete everything under `/build/contracts` and re-run the steps above.
  - If you get this error `Error: sender doesn't have enough funds to send tx` restart testrpc (you ran out of test ether)
  - Or else the problem is with your code. Good luck.
 
 
### Schema in Ver 0.2.0. 
Contracts are modular meaning they can be exchanged for updated contracts and disregard the old EXCEPT the Data contracts.  

** Deploy contracts schema.    
Remeber only the wallet used to deploy these contracts are the 'owner'. The role gives him/her rights to swap addresses.
-  Deploy 'Data' contracts. Save the address to be used for manager contracts.  
-  Deploy 'Manager' contracts second and insert the 'Data' contract address. For example AssetData.sol is being used with AssetManager.sol. Now go back go the correlating data contract and setManager(manager address). This will set security of what contracts are allowed to perform certain functions.  
-  Deploy the SplyManager contract and pass the addresses of all the managers in the constructor.  


** Updating manager contracts.  
-  All contracts except the data contracts can be abandoned. Thus updated versions of the contract can be bined with the existing data contracts.
-  After updating any of the managerial contracts, you can change ownership to the new managerial contracts in the following steps.
1.  



