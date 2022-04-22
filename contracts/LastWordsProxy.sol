//SPDX-License-Identifier:996ICU AND apache-2.0
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";

contract LastWordsProxy is ERC1967Proxy(0x549AF41c592590a0907864C946467cb3795Fe193,new bytes(0)) {}