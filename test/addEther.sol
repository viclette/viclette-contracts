// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract AddEther_Test is BaseTest {
    function setUp() public override {
        BaseTest.setUp();
    }

    function test_addEther() public {
        assertEq(address(viclette).balance, 0.01 ether);
        viclette.addEther{value: 1 ether}();
        assertEq(address(viclette).balance, 1.01 ether);
    }
}
