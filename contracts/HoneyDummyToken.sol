// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// Just a dummy token I was using for testing
contract Honey is ERC20 {
    constructor() ERC20("Honey", "HNY") {
        _mint(msg.sender, 10000 * 10 ** decimals());
    }
}


