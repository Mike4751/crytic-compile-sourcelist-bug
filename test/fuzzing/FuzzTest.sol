// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@external/interfaces/IOracle.sol";
import "@external/interfaces/IPrice.sol";
import "mylib/Base.sol";
import "mylib/Helper.sol";
import "contracts/Main.sol";

// Fuzz test that imports everything
// When built from this subdirectory with relative paths,
// the same files get different path representations

contract FuzzTest {
    Main public main;
    HelperUser public helper;

    constructor() {
        main = new Main(address(0));
        helper = new HelperUser();
    }

    function fuzz_setValue(uint256 val) external {
        main.setValue(val);
        require(main.getValue() == val, "Value mismatch");
    }

    function fuzz_setDoubled(uint256 val) external {
        helper.setDoubled(val);
    }
}
