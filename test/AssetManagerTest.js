const AssetManager = artifacts.require("../Protocol/AssetManager.sol");
const SplytManager = artifacts.require("../Protocol/SplytManager.sol");
const ManagerTracker = artifacts.require("../Protocol/ManagerTracker.sol");

const ShopxToken = artifacts.require("../Token/ShopxToken.sol");
const Stake = artifacts.require("../Protocol/Stake.sol");
const Asset = artifacts.require("../Protocol/Asset.sol");


contract('AssetManagerTest general test cases.', function(accounts) {

  const defaultBuyer = accounts[0];
  const defaultSeller = accounts[1];
  const defaultMarketPlace = accounts[2];

  let shopxTokenInstance;
  let assetManagerInstance;
  let splytManagerInstance;
  let assetInstance;
  let stakeInstance;

  async function create_asset(_assetId = "0x31f2ae92057a7123ef0e490a", _term = 0, _seller = defaultSeller, _title = "MyTitle",
      _totalCost = 1000000, _expirationDate = 10001556712588, _mpAddress = defaultMarketPlace, _mpAmount = 2, _inventoryCount = 2) {
    
    // let managerTrackerAddress = await splytManagerInstance.getManagerTrackerAddress();
    var walletConfig = {
      value: 1234567890123456789
    }
    await assetManagerInstance.ethToShopx(_assetId, _term, _seller, _title, _totalCost, _expirationDate, _mpAddress, _mpAmount, _inventoryCount, walletConfig);
    assetAddress = await assetManagerInstance.getAddressById(_assetId);
    assetInstance = await Asset.at(assetAddress);

  }

  // This function gets ran before every test cases in this file.
  before('Default instances of contracts for each test', async function() {
    console.log('Deploy contracts')
    shopxTokenInstance = await ShopxToken.deployed()   
    assetManagerInstance = await AssetManager.deployed();
    splytManagerInstance = await SplytManager.deployed();
    managerTrackerInstance = await ManagerTracker.deployed();
    stakeInstance = await Stake.deployed();

    accounts.forEach(async function(acc) {
      await shopxTokenInstance.initUser(acc, 205000000)
    })

  })

  it('should get manager tracker address successfully!', async function() {
    // await create_asset();
    let managerTrackerAddress = await splytManagerInstance.getManagerTrackerAddress();
    console.log('manager tracker address: ' + managerTrackerAddress);
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(managerTrackerAddress, 0x0, "managerTracker has not been deployed!");
  })


  it('should create new asset manager contract successfully!', async function() {
    
    let assetManagerAddress = assetManagerInstance.address;

    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(assetManagerAddress, 0x0, "AssetManager has not been deployed!");
  })

  it('should deploy new asset contract successfully!', async function() {
    await create_asset();
    console.log('asset deployed using new passthrough')
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    assert.notEqual(assetInstance.address, 0x0, "Asset contract has not been deployed!");
    console.log('now checking balance of asset manager')
    var balance = await assetManagerInstance.getBalance();
    var balance2 = await assetManagerInstance.getBalanceOfWallet();

    console.log('balance of contract', balance.toString());
    console.log('balance of wallet', balance2.toString());
  })


  it('should get stake amount from asset!', async function() {
    let stakeAmount = await assetInstance.initialStakeAmount();
    console.log('stake amount: ' + stakeAmount);

    let stakeAmount2 = await stakeInstance.calculateStakeTokens(1000000);
    console.log('stake amount(Stake Contract): ' + stakeAmount2);
    assert.equal(parseInt(stakeAmount), parseInt(stakeAmount2), "Expected stake amount does not match!");
  })

  it('should status be 1=ACTIVE if asset is available for purchase!', async function() {
    await create_asset();
    // assert.equal(orderId, , 'No money should be transfered to seller\'s wallet!');
    let status = await assetInstance.status();
    // console.log('status: ' + status);
    assert.equal(status, 1, "Asset status is NOT 1=ACTIVE as expected!");
  })

  it('should status be 2=IN_ARBITRATION', async function() {
    await create_asset();

    // console.log('asset address: ' + assetAddress);
    await assetManagerInstance.setStatus(assetAddress, 2);
    let status = await assetInstance.status();
    // console.log('status: ' + status);
    assert.equal(status, 2, "Asset status is NOT 2=IN_ARBITRATION as expected!");
  })


  it('should status be 3=EXPIRED', async function() {
    await create_asset();

    // console.log('asset address: ' + assetAddress);
    await assetManagerInstance.setStatus(assetAddress, 3);
    let status = await assetInstance.status();
    // console.log('status: ' + status);
    assert.equal(status, 3, "Asset status is NOT 3=EXPIRED as expected!");
  })

  it('should status be 4=CLOSED', async function() {
    await create_asset();

    // console.log('asset address: ' + assetAddress);
    await assetManagerInstance.setStatus(assetAddress, 4);
    let status = await assetInstance.status();
    //  console.log('status: ' + status);
    assert.equal(status, 4, "Asset status is NOT 4=CLOSED as expected!");
  })

  it('should asset id 0x31f2ae92057a7123ef0e490a', async function() {
    await create_asset();

    // console.log('asset address: ' + assetAddress);
    let assetInfos = await assetManagerInstance.getAssetInfoByAddress(assetAddress);
    console.log('asset id: ' + assetInfos[1]);
    // console.log('asset term: ' + assetInfos[1]);
    // console.log('assset inventory: ' + assetInfos[2]);
    assert.equal(assetInfos[1], "0x31f2ae92057a7123ef0e490a", "Asset id is different than expected!");
  })

  it('should return title MyTitle', async function() {
    await create_asset();

    // console.log('asset address: ' + assetAddress);
    let title = await assetInstance.title();
    // console.log('asset title: ' + title);
    assert.equal(title, "MyTitle", "Asset title is different than expected!");
  })

  it('should return inventory of 1', async function() {
    await create_asset();

    // console.log('asset address: ' + assetAddress);
    let count = await assetInstance.inventoryCount();
    // console.log('asset inventory: ' + count);
    assert.equal(count, 2, "Asset inventory is different than expected!");
  })

  it('should interate through list of assets', async function() {
    let index = await assetManagerInstance.getAssetsLength();
    for (let i = 0; i < index; i++) {
      // console.log('index: ' + i)
      let fields = await assetManagerInstance.getAssetInfoByIndex(i)
      // console.log('asset info: ' + fields);      
    }
    // console.log('asset inventory: ' + count);
    // assert.equal(count, 2, "Asset inventory is different than expected!");
  })



  async function sleep(milliseconds) {
    return new Promise(resolve => setTimeout(resolve, milliseconds));
  }
})