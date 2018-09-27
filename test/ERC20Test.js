// satTokens.sol extends ERC20.sol thus truffle won't know about ERC20 but it will have all functions
//  from ERC20 in satToken.sol
const satToken = artifacts.require("./SatToken.sol");
var SplytTracker = artifacts.require("./SplytTracker.sol")

contract('ERC20 general test cases.', function(accounts) {

  let erc20Instance;
  const defaultTokenAmount = 205000000;

  beforeEach('Deploying ERC20 contract. ', async function() {
    erc20Instance = await satToken.deployed();
  })

  it('totalSupply() function retrieves value of totalTokensAllowed variable.', async function() {
    let totalSupl = await erc20Instance.totalSupply.call();
    assert.equal(totalSupl, 64321684210000, 'Value should be equal totalTokensAllowed.');
  })

  it('balanceOf() function retrieves user\'s balance = zero.', async function() {
    let bal = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(bal, 0, 'Value should be 0!');
  })

  it('initUser() adds to users account 205000000 tockens and balanceOf() function retrieves user\'s balance.', async function() {
    let bal = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(bal, 0, 'Value should be 0!');
    await erc20Instance.initUser(accounts[1]);
    let bal2 = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(bal2, defaultTokenAmount, 'Value should be 0!');
  })

  // This should fail if user A hasn't allowed the transfer based on allowance.
  it('transferFrom() function transfers tockenf from one wallet to another.', async function() {
    await erc20Instance.initUser(accounts[1]);
    let bal2 = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(bal2, defaultTokenAmount, 'Value should be >= 205000000!');
    let bal3 = await erc20Instance.balanceOf(accounts[2]);
    await erc20Instance.transferFrom(accounts[1], accounts[2], 200000000);
    let bal4 = await erc20Instance.balanceOf(accounts[2]);
    assert.equal(Number(bal3) + Number(bal4), 200000000, 'Value should be >= 200000000!');
    let bal5 = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(bal5, 5000000, 'Value should be 5000000!');
  })

  it('transferFrom() function does NOT transfer tockenf from one wallet to another because of not enought tockens in the wallet.', async function() {
    await erc20Instance.initUser(accounts[1]);
    await erc20Instance.initUser(accounts[2]);
    let bal2 = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(bal2, defaultTokenAmount, 'Value should be >= 205000000!');
    let bal3 = await erc20Instance.balanceOf(accounts[2]);
    await erc20Instance.transferFrom(accounts[1], accounts[2], 300000000);
    let bal4 = await erc20Instance.balanceOf(accounts[2]);
    assert.equal(Number(bal3), Number(bal4), 'Value should be >= 205000000!');
    let bal5 = await erc20Instance.balanceOf(accounts[1]);
    assert.equal(Number(bal5), Number(bal2), 'Value should be 205000000!');
  })

  it('transfer() function transfers tockens from one wallet to another.', async function() {
    await erc20Instance.initUser(accounts[2]);
    await erc20Instance.initUser(accounts[0]);
    let bal3 = await erc20Instance.balanceOf(accounts[2]);
    var isTrans = await erc20Instance.transfer(accounts[2], 20000);
    let bal4 = await erc20Instance.balanceOf(accounts[2]);
    assert.equal((Number(bal3) + 20000), Number(bal4), 'Value should be >= 20000!');
  })

  it('getBalance() function returns wallet\'s balance.', async function() {
    let bal0 = await erc20Instance.getBalance();
    assert.equal(Number(bal0), 0, 'Value should be 0!');
  })

  // it('allowance() function returns allowance value.', async function() {
  //   // await erc20Instance.initUser(accounts[1]);
  //   // await erc20Instance.initUser(accounts[2]);
  //   let appr = await erc20Instance.approve.call(accounts[2], 100);
  //   console.log('appr is: ', appr);
  //   let all = await erc20Instance.allowance(accounts[1], accounts[2]);
  //   let all2 = await erc20Instance.allowance(accounts[2], accounts[1]);
  //   console.log('all is: ', all.valueOf());
  //   console.log('all2 is: ', all2.valueOf());
  //   // assert.equal((Number(bal3) + 20000), Number(bal4), 'Value should be >= 20000!');
  // })

})