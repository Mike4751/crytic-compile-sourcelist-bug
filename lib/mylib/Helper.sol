// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Base.sol";

// Helper that extends Base
library Helper {
    function double(uint256 x) internal pure returns (uint256) {
        return x * 2;
    }
}

contract HelperUser is Base {
    using Helper for uint256;

    function setDoubled(uint256 val) external {
        _setValue(val.double());
    }
}
