// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Simple contract with no dependencies
contract A {
    uint256 public a;

    function setA(uint256 _a) external {
        a = _a;
    }
}
