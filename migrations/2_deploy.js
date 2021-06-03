const HoneyBees = artifacts.require("HoneyBees");

// Set 1Hive Agent address from:
/// https://wiki.1hive.org/developers/developers
const DAOAgentAddress = '0x4ba7362f9189572cbb1216819a45aba0d0b2d1cb';

// Set Honey Token Address from 
/// https://blockscout.com/poa/xdai/address/0x71850b7E9Ee3f13Ab46d67167341E4bDc905Eef9
const honeyTokenAddress = '0x71850b7E9Ee3f13Ab46d67167341E4bDc905Eef9';



module.exports = function (deployer) {
  deployer.deploy(HoneyBees, honeyTokenAddress, DAOAgentAddress);
};
