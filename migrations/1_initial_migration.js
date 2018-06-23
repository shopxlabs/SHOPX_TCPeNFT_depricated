var Migrations = artifacts.require("./Migrations.sol");
var SatToken = artifacts.require("./SatToken.sol");
var SplytTracker = artifacts.require("./SplytTracker.sol");
var Arbitrator = artifacts.require("./Arbitrator.sol");

module.exports = function(deployer) {
  var name = "SPLYT";
  var desc = "Global inventory on the blockchain";
  var ver  = 3;

  deployer.deploy(Migrations);

  deployer.deploy(SatToken, name, desc, ver)
  .then(async function() {
    var arbitrator = await deployer.deploy(Arbitrator);
    var deployed = await deployer.deploy(SplytTracker, ver, name, SatToken.address, arbitrator.address);
  });
};
