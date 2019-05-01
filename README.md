# splytprotocol
Ethereum contracts for split protocol

### Setup:
 - `git clone https://github.com/splytcore/splytprotocol.git`
 - `npm install truffle -g`
 - `npm install ganache-cli -g`

### Run:
 - In terminal `ganache-cli`. Leave terminal tab open
 - In another terminal `cd path/to/project`
 - `truffle compile`. Will compile all contracts
 - `truffle migrate --reset`. Will deploy all contracts to testrpc network
 - `truffle test ./test/[fileName].js`. Will test all functions in that file. Also `truffle test` will run all test in the test folder
 
 
### Things to look out for: 
 
  - Truffle doesn't like OSX folder `.DS_Store` so keep an eye for it in `/build/contracts` folder as well as anywhere else in the project. Remove that folder and run the instructions again if issues arise.
  - If you still have problems delete everything under `/build/contracts` and re-run the steps above.
  - If you get this error `Error: sender doesn't have enough funds to send tx` restart testrpc (you ran out of test ether).
  - Or else the problem is with your code. Good luck.
 
### Progress:
 
#### Completed:

  - Fractional Listings
  - Standard Listings
  - Fractional buys
  - Standard buys
  - Listing commissions 
  - Listing stakes as seller
  - Arbitration mitigation where seller puts 2x stakes and spam reported puts 2x stakes
    - In case of arbitration spam reporter puts 2x stakes
    - Seller also puts in 2x stakes
    - 3rd party arbitrator finds truth and distributes stake funds to winner/looser
  - ERC20 token contract
    - Blacklisting wallets as sellers, buyers, arbitrators
    - Whitelisting group of splyt contracts for security
    - 4 decimal places to allow currency denomination
  - Splyt javascript library for easy plug and play
  
#### Missing:
 
 - NPM module for even easier plug and play functionality
 - ERC20 token distribution model
 - FIAT -> SAT -> FIAT conversions
 - Shopify app for auto pull push to seller's online store
 - ERC721 implementation (maybe)
  
 
