// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import "../../src/Viclette.sol";

contract MockViclette is Viclette {
    constructor(address vrfContract_) Viclette(vrfContract_) {}

    /// @dev Mocks the result of increasing winnings for a player.
    /// @param player Address of the player to increase winnings for
    /// @param amount Amount to increase winnings by
    function addWinnings(address player, uint256 amount) public {
        winnings[player] += amount;
    }
}
