// SPDX-License-Identifier: MIT
/// @title Honey Bees
/// @author sirwithacomputer
/// @notice This contract wraps HNY into BEES at a 1:1,000,000 Ratio.
/// You can unwrap your honey at any time by sending bees back to the contract...
/// 🐝🐝🐝🍯🍯🍯🍯🍯🍯🍯🍯🍯🐝🐝🐝

////////////////////////////////////////////////////////
/// 🐝🐝 ONLY SEND BEES TO THE CONTRACT! ///////////////
/// 🚨🍯 DO NOT SEND HONEY TO THE CONTRACT!/////////////
////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////
// Contract has not been audited. This is just a project for fun.
// Use at your own risk!
// I made this using YFI's woofy as an inspiration.
// Feel free to reuse or modify the code as you like.
// Cheers 🍻
////////////////////////////////////////////////////////////////////



pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Adding a snapshotrole so holders can still vote on 1Hive (if so decided by the DAO) 
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract HoneyBees is ERC20, ERC20Snapshot, AccessControl {

    
    ERC20 public honeyAddress; 

    bytes32 public constant SNAPSHOT_ROLE = keccak256("SNAPSHOT_ROLE");
    
    // Set 1Hive Agent address in deployer
    address public honeyDAOAgentAddress;

    constructor(address honeyTokenAddress, address DAOAgentAddress) ERC20("HoneyBees", "BEES") {

      // Giving control (and snapshot ability) to the 1Hive Aragon Agent
        honeyAddress = ERC20(honeyTokenAddress);

        honeyDAOAgentAddress = DAOAgentAddress;

        _setupRole(DEFAULT_ADMIN_ROLE, honeyDAOAgentAddress);
        _setupRole(SNAPSHOT_ROLE, honeyDAOAgentAddress);
    }
    
    function decimals() public view virtual override returns (uint8) {

        // This is what give us our HNY/BEES ratio. Right now, I just did 1:1,000,000
        return 12;
    }

    function attractBees() public returns (bool) {
        
        require(honeyAddress.balanceOf(msg.sender) > 0);
        uint256 amountOfHoney = honeyAddress.balanceOf(msg.sender);      
        uint256 expectedNewContractHoneyBalance = honeyAddress.balanceOf(address(this)) + amountOfHoney;
        uint256 expectedNewUserBeeBalance = this.balanceOf(msg.sender) + amountOfHoney;
        
        honeyAddress.transferFrom(msg.sender, address(this), amountOfHoney);
        
        require(honeyAddress.balanceOf(address(this)) == expectedNewContractHoneyBalance);
        mint(msg.sender, amountOfHoney);

        require(this.balanceOf(msg.sender) == expectedNewUserBeeBalance);
        return true;
    }

    function attractBees(uint256 amountOfHoney) public returns (bool) {
        
        require(honeyAddress.balanceOf(msg.sender) >= amountOfHoney);
        uint256 expectedNewContractHoneyBalance = honeyAddress.balanceOf(address(this)) + amountOfHoney;
        uint256 expectedNewUserBeeBalance = this.balanceOf(msg.sender) + amountOfHoney;

        honeyAddress.transferFrom(msg.sender, address(this), amountOfHoney);
        
        require(honeyAddress.balanceOf(address(this)) == expectedNewContractHoneyBalance);
        _mint(msg.sender, amountOfHoney);

        require(this.balanceOf(msg.sender) == expectedNewUserBeeBalance);
        return true;
    }

    function attractBees(uint256 amountOfHoney, address sendTo) public returns (bool) {

        require(honeyAddress.balanceOf(msg.sender) >= amountOfHoney);
        uint256 expectedNewContractHoneyBalance = honeyAddress.balanceOf(address(this)) + amountOfHoney;
        uint256 expectedNewUserBeeBalance = this.balanceOf(msg.sender) + amountOfHoney;

        honeyAddress.transferFrom(msg.sender, address(this), amountOfHoney);

        require(honeyAddress.balanceOf(address(this)) == expectedNewContractHoneyBalance);
         _mint(sendTo, amountOfHoney);

        require(this.balanceOf(msg.sender) == expectedNewUserBeeBalance);
        return true;
    }
    
    function collectHoney() public returns (bool) {

        require(this.balanceOf(msg.sender) >= 0);
        uint256 numberOfBees = this.balanceOf(msg.sender);
        uint256 expectedNewContractHoneyBalance = honeyAddress.balanceOf(address(this)) - numberOfBees;   
        uint256 expectedNewUserBeeBalance = this.balanceOf(msg.sender) - numberOfBees;

        _burn(msg.sender, numberOfBees);

        require(this.balanceOf(msg.sender) == expectedNewUserBeeBalance);
        honeyAddress.transfer(msg.sender, numberOfBees);
  
        require(this.balanceOf(address(this)) == expectedNewContractHoneyBalance);
        return true;
    }

    function collectHoney(uint256 numberOfBees) public returns (bool) {

        require(this.balanceOf(msg.sender) >= numberOfBees);
        uint256 expectedNewContractHoneyBalance = honeyAddress.balanceOf(address(this)) - numberOfBees;
        uint256 expectedNewUserBeeBalance = this.balanceOf(msg.sender) - numberOfBees;
         
        _burn(msg.sender, numberOfBees);
         
        require(this.balanceOf(msg.sender) == expectedNewUserBeeBalance); 
        honeyAddress.transfer(msg.sender, numberOfBees);
        
        require(this.balanceOf(address(this)) == expectedNewContractHoneyBalance);
        return true;
    }

    function collectHoney(uint256 numberOfBees, address sendTo) public returns (bool) {

        require(this.balanceOf(msg.sender) >= numberOfBees);
         uint256 expectedNewContractHoneyBalance = honeyAddress.balanceOf(address(this)) - numberOfBees;
         uint256 expectedNewUserBeeBalance = this.balanceOf(msg.sender) - numberOfBees;

         _burn(msg.sender, numberOfBees);

        require(this.balanceOf(msg.sender) == expectedNewUserBeeBalance);
         honeyAddress.transfer(sendTo, numberOfBees);
        
        require(this.balanceOf(address(this)) == expectedNewContractHoneyBalance);
         return true;
    }


    function transfer(address recipient, uint256 amount) public virtual override (ERC20)
        returns (bool)
    {
        if (recipient == address(this)) {
            collectHoney(amount, msg.sender);
            return true;
        } else {
        super.transfer(recipient, amount);        }
    }

    function snapshot() public {
        require(hasRole(SNAPSHOT_ROLE, msg.sender));
        _snapshot();
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal
        override(ERC20, ERC20Snapshot)
    {
        super._beforeTokenTransfer(from, to, amount);
    }

}