// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

// Base contract in lib/ (like forge-std)
// In GMX, lib/forge-std files had HIGHER IDs but appeared FIRST in JSON

contract Base {
    uint256 internal _value;

    function _setValue(uint256 val) internal {
        _value = val;
    }

    function _getValue() internal view returns (uint256) {
        return _value;
    }
}
