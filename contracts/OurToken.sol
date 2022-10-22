// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract OurToken is ERC20 {
    constructor(uint256 initialSupply) ERC20("SampleToken", "SOT") {
        // minting initial amount of tokens using _mint of openzeppelin ERC-20 _mint function
        // deployer will have all the tokens in the beginning

        _mint(msg.sender, initialSupply);
    }
}
