// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./B.sol";

// Contract that inherits from B (which inherits from A)
contract C is B {
    uint256 public c;

    function setC(uint256 _c) external {
        c = _c;
    }
}
