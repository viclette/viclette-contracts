// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Solarray} from "solarray/Solarray.sol";

import {MockViclette} from "./mocks/MockViclette.sol";

import {BaseTest} from "./Base.t.sol";

contract SyncWinnings_Test is BaseTest {
    MockViclette vicletteV2;

    function setUp() public override {
        BaseTest.setUp();
        changePrank(owner);
        vicletteV2 = new MockViclette(address(vrfService));
    }

    function test_RevertWhen_NotOldViclette() public {
        vm.expectRevert("not old viclette");
        vicletteV2.syncWinnings(address(viclette));
    }

    function test_syncWinnings() public {
        _prepareToMigrate();
        assertEq(vicletteV2.winnings(player), 0 ether);
        assertEq(viclette.winnings(player), 1 ether);

        vm.expectEmit(true, true, true, true, address(viclette));
        emit WinningsMigrated(player, 1 ether);

        vm.expectEmit(true, true, true, true, address(vicletteV2));
        emit WinningsSynced(player, 1 ether);

        changePrank(player);
        vicletteV2.syncWinnings(address(viclette));
        // assert that the contract is paused
        assertTrue(viclette.paused());
        vm.expectRevert("contract is paused");
        placeDefaultBets();

        // assert that the winnings were synced
        assertEq(vicletteV2.winnings(player), 1 ether);
        assertEq(viclette.winnings(player), 0 ether);
        assertEq(address(vicletteV2).balance, 0 ether);
    }

    function _prepareToMigrate() internal {
        addWinnings(player, 1 ether);
        vm.expectEmit(true, true, true, true);
        emit Migrated(address(vicletteV2));
        viclette.migrateToNewViclette(address(vicletteV2));

        vm.expectEmit(true, true, true, true);
        emit OldViclettesSet(Solarray.addresses(address(viclette)));
        vicletteV2.setOldViclettes(Solarray.addresses(address(viclette)));
    }
}
