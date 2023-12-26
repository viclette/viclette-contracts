// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title VicletteStorage
 * @dev Storage contract for the Viclette betting game.
 * This abstract contract defines the core storage structure used by Viclette.
 */
abstract contract VicletteStorage {
    // Counter for the nonce value, used in random number generation
    uint64 internal nonce;

    // Minimum betting amount allowed in the game
    uint256 public minBetAmount;

    // Maximum amount of Ether allowed to be held in the contract's bank
    uint256 public maxAmountAllowedInBank;

    // Timestamp for the next allowed random number request
    uint256 public nextRequestTimestamp;

    // ID of the last random number request
    uint256 public lastRequestId;

    // Array defining payouts for each bet type
    uint8[] public payouts;

    // Array defining the number range for each bet type
    uint8[] public numberRange;

    // Mapping from player address to their winnings balance
    mapping(address => uint256) public winnings;

    mapping(address => bool) public isOldViclette;

    // Flag to indicate if a random number request is currently ongoing
    bool public requested;

    // Flag to indicate if the game is currently paused
    bool public paused;

    // Address of the new Viclette contract
    address public newViclette;

    /**
     * @dev Struct representing a bet in the game.
     * @param player Address of the player placing the bet
     * @param betType Type of the bet (e.g., color, column, dozen, etc.)
     * @param number Bet number chosen by the player
     * @param amount Amount of Ether bet by the player
     * @notice Bet types are as follows:
     * - 0: color (0 for black, 1 for red)
     * - 1: column (0 for left, 1 for middle, 2 for right)
     * - 2: dozen (0 for first, 1 for second, 2 for third)
     * - 3: eighteen (0 for low, 1 for high)
     * - 4: modulus (0 for even, 1 for odd)
     * - 5: number (0 ~ 37, 0 for single zero, 37 for double zero)
     * Depending on the BetType, the number will be within the specified range.
     */
    struct Bet {
        address player;
        uint8 betType;
        uint8 number;
        uint256 amount;
    }

    // Internal array of bets placed in the current round
    Bet[] internal _bets;
}
