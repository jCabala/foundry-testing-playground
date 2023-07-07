// SPDX-LIcense-Identifier: MIT
pragma solidity ^0.8.17;

import "solmate/tokens/ERC20.sol";

contract Token is ERC20("name", "symbol", 18) {}

import "@openzeppelin/contracts/access/Ownable.sol";

contract TestOz is Ownable {}
