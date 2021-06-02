const HoneyBees = artifacts.require("HoneyBees");

module.exports = function (deployer) {
  deployer.deploy(HoneyBees);
};
