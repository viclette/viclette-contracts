// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract ReturnBets_Test is BaseTest {
    function setUp() public override {
        BaseTest.setUp();
    }

    function test_ReverWhen_NotOwner() public {
        vm.expectRevert("Ownable: caller is not the owner");
        viclette.returnBets();
    }

    function test_returnBets() public {
        placeDefaultBets();
        assertTrue(viclette.getBets().length != 0);

        (uint256 nextRoundTimestamp, uint256 balance, uint256 winnings) = viclette.getStatus();
        assertEq(nextRoundTimestamp, nowTimestamp);
        assertEq(balance, 0.01 ether + 3 ether);
        assertEq(winnings, 0);

        assertEq(address(player).balance, 97 ether);

        // request random number and return bets
        viclette.requestRandomNumber();

        // to let MockVRFService return false
        if (nowTimestamp % 2 != 0) {
            vm.warp(nowTimestamp + 1);
        }
        changePrank(owner);
        viclette.returnBets();

        changePrank(player);
        (, balance, winnings) = viclette.getStatus();
        assertEq(balance, 0.01 ether + 3 ether);
        assertEq(winnings, 3 ether);
        assertEq(viclette.getBets().length, 0);
    }
}
