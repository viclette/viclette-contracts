// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {BaseTest} from "./Base.t.sol";

contract SpinWheel_Test is BaseTest {
    function test_spinWheel() public {
        placeDefaultBets();

        (uint256 nextRoundTimestamp, uint256 balance, uint256 winnings) = viclette.getStatus();
        assertEq(nextRoundTimestamp, nowTimestamp);
        assertEq(balance, 0.01 ether + 3 ether);
        assertEq(winnings, 0);

        assertEq(address(player).balance, 97 ether);

        // request random number and spin the wheel
        viclette.requestRandomNumber();
        vm.expectEmit(true, true, true, true);
        emit ProfitTaken(owner, 3 ether);
        vm.expectEmit(true, true, true, true);
        emit RandomNumber(0);
        // to let MockVRFService return true
        if (nowTimestamp % 2 == 0) {
            vm.warp(nowTimestamp + 1);
        }
        viclette.spinWheel();
        assertEq(viclette.getBets().length, 0);

        (, balance, winnings) = viclette.getStatus();
        assertEq(balance, 0.01 ether);
        assertEq(winnings, 1 ether * 36);
        assertEq(address(player).balance, 97 ether);
        assertEq(address(owner).balance, 100 ether + 3 ether);
    }
}
