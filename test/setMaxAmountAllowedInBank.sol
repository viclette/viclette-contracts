// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract SetMaxAmountAllowedInBank_Test is BaseTest {
    function setUp() public override {
        BaseTest.setUp();
        changePrank(owner);
    }

    function test_RevertWhen_NotOwner() public {
        changePrank(player);
        vm.expectRevert("Ownable: caller is not the owner");
        viclette.setMaxAmountAllowedInBank(1 ether);
    }

    function test_setMinBetAmount() public {
        // assert that the max amount allowed in the bank is 0.01 ether by default
        assertEq(viclette.maxAmountAllowedInBank(), 0.01 ether);

        // set the max amount allowed in the bank
        viclette.setMaxAmountAllowedInBank(1 ether);

        // assert that the max amount allowed in the bank was set
        assertEq(viclette.maxAmountAllowedInBank(), 1 ether);
    }
}
