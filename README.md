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
  - If you get this error `Error: sender doesn't have enough funds to send tx` restart testrpc (you ran out of test ether).
  - Or else the problem is with your code. Good luck.
 
 
