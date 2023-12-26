// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract CashOut_Test is BaseTest {
    function setUp() public override {
        BaseTest.setUp();
    }

    function test_RevertWhen_NoWinnings() public {
        vm.expectRevert("no winnings");
        viclette.cashOut();
    }

    function test_cashOut_WhenWinningsGreaterThanBalance() public {
        addWinnings(player, 1 ether);
        vm.expectEmit(true, true, true, true);
        emit CashOut(player, 0.01 ether);
        viclette.cashOut();

        assertEq(address(player).balance, 100 ether + 0.01 ether);
        assertEq(address(viclette).balance, 0 ether);
    }

    function test_cashOut_WhenWinningsLessThanBalance() public {
        addWinnings(player, 0.0036 ether);
        vm.expectEmit(true, true, true, true);
        emit CashOut(player, 0.0036 ether);
        viclette.cashOut();

        assertEq(address(player).balance, 100 ether + 0.0036 ether);
        assertEq(address(viclette).balance, 0.01 ether - 0.0036 ether);
    }
}
