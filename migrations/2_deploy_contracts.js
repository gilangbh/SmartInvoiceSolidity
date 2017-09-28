var SmartInvoice = artifacts.require("./SmartInvoice/SmartInvoice.sol");

module.exports = function(deployer) {
  deployer.deploy(SmartInvoice);
};