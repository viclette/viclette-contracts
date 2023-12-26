// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title IVicletteEvent
 * @dev Interface for Viclette game events.
 * This interface defines events emitted by the Viclette game contract.
 */
interface IVicletteEvent {
    /**
     * @dev Emitted when a new random number is generated for the game round.
     * @param number The random number generated.
     */
    event RandomNumber(uint256 indexed number);

    /**
     * @dev Emitted when a player places a bet.
     * @param player The address of the player placing the bet.
     * @param betType The type of bet placed.
     * @param number The number on which the bet is placed.
     * @param amount The amount of ether bet.
     */
    event BetPlaced(address indexed player, uint8 indexed betType, uint8 indexed number, uint256 amount);

    /**
     * @dev Emitted when a player cashes out their winnings.
     * @param player The address of the player cashing out.
     * @param amount The amount of ether cashed out.
     */
    event CashOut(address indexed player, uint256 indexed amount);

    /**
     * @dev Emitted when the minimum bet amount is set.
     * @param minBetAmount The new minimum bet amount.
     */
    event MinBetAmountSet(uint256 indexed minBetAmount);

    /**
     * @dev Emitted when the maximum amount allowed in the bank is set.
     * @param maxAmountAllowedInBank The new maximum amount allowed in the bank.
     */
    event MaxAmountAllowedInBankSet(uint256 indexed maxAmountAllowedInBank);

    /**
     * @dev Emitted when the Verifiable Random Function (VRF) contract is set.
     * @param vrfContract The address of the VRF contract.
     */
    event VRFContractSet(address indexed vrfContract);

    /**
     * @dev Emitted when a request for a random number is sent.
     * @param requestId The identifier of the request.
     * @param seed The seed used for the random number generation.
     */
    event RequestSent(uint256 indexed requestId, string seed);

    /**
     * @dev Emitted when profits are taken from the contract.
     * @param amount The amount of ether taken as profits.
     */
    event ProfitTaken(address indexed owner, uint256 indexed amount);

    /**
     * @dev Emitted when bets are returned to players.
     * @param requestId The identifier of the request for which bets are returned.
     */
    event BetReturned(uint256 indexed requestId);

    /**
     * @dev Emitted when the game is paused.
     * @param newViclette The address of the new Viclette contract.
     */
    event Migrated(address indexed newViclette);

    /**
     * @dev Emitted when the old Viclette contract is set.
     * @param oldViclettes The addresses of the old Viclette contracts.
     */
    event OldViclettesSet(address[] indexed oldViclettes);

    /**
     * @dev Emitted when a player's winnings are migrated to the new Viclette contract.
     * @param player The address of the player.
     * @param amount The amount of winnings migrated.
     */
    event WinningsMigrated(address indexed player, uint256 indexed amount);

    /**
     * @dev Emitted when a player's winnings are synced from the old Viclette contract.
     * @param player The address of the player.
     * @param amount The amount of winnings synced.
     */
    event WinningsSynced(address indexed player, uint256 indexed amount);
}
