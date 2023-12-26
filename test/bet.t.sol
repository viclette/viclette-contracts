// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract Bet_Test is BaseTest {
    function setUp() public override {
        BaseTest.setUp();
    }

    function test_bet() public {
        vm.expectEmit(true, true, true, true);
        emit BetPlaced(player, 5, 0, 1 ether);

        vm.expectEmit(true, true, true, true);
        emit BetPlaced(player, 5, 1, 1 ether);

        vm.expectEmit(true, true, true, true);
        emit BetPlaced(player, 5, 2, 1 ether);

        placeDefaultBets();

        // assert that the bets were placed
        (uint256 nextRoundTimestamp, uint256 balance, uint256 winnings) = viclette.getStatus();
        assertEq(nextRoundTimestamp, nowTimestamp);
        assertEq(balance, 0.01 ether + 3 ether);
        assertEq(winnings, 0);
        assertEq(address(player).balance, 97 ether);
    }
}
