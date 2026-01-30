// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./A.sol";

// Contract that inherits from A
contract B is A {
    uint256 public b;

    function setB(uint256 _b) external {
        b = _b;
    }
}
