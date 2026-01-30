// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@external/interfaces/IOracle.sol";
import "mylib/Base.sol";

// Main contract using both node_modules and lib dependencies
contract Main is Base {
    IOracle public oracle;

    constructor(address _oracle) {
        oracle = IOracle(_oracle);
    }

    function setValue(uint256 val) external {
        _setValue(val);
    }

    function getValue() external view returns (uint256) {
        return _getValue();
    }
}
