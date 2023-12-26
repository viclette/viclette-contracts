// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract SetMinBetAmount_Test is BaseTest {
    function setUp() public override {
        BaseTest.setUp();
        changePrank(owner);
    }

    function test_RevertWhen_NotOwner() public {
        changePrank(player);
        vm.expectRevert("Ownable: caller is not the owner");
        viclette.setMinBetAmount(1 ether);
    }

    function test_setMinBetAmount() public {
        // assert that the min bet amount is 0.0001 ether by default
        assertEq(viclette.minBetAmount(), 0.0001 ether);

        // set the min bet amount
        viclette.setMinBetAmount(1 ether);

        // assert that the min bet amount was set
        assertEq(viclette.minBetAmount(), 1 ether);
    }
}
