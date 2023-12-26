// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {VicletteStorage} from "../VicletteStorage.sol";
import {IVicletteEvent} from "./IVicletteEvent.sol";

/**
 * @title IViclette
 * @dev Interface for the Viclette Betting Game Contract.
 * This interface outlines the external functions implemented by the Viclette contract.
 */
interface IViclette is IVicletteEvent {
    /**
     * @notice Allows the contract to receive Ether.
     */
    function addEther() external payable;

    /**
     * @notice Places bets for the current round.
     * @param bets_ Array of bet structs for the round.
     */
    function bet(VicletteStorage.Bet[] memory bets_) external payable;

    /**
     * @notice Spins the wheel to determine winning bets.
     */
    function spinWheel() external;

    /**
     * @notice Allows players to cash out their winnings.
     */
    function cashOut() external;

    /**
     * @notice Returns bets if the random number request is not ready.
     * Only callable by the contract owner.
     */
    function returnBets() external;

    /**
     * @notice Migrates the contract to a new Viclette contract.
     * @param newViclette_ Address of the new Viclette contract.
     */
    function migrateToNewViclette(address newViclette_) external;

    /**
     * @notice Syncs the player's winnings to the new Viclette contract.
     * @param player_ Address of the player.
     * @return amount_ The amount of winnings to sync.
     */
    function migrateWinnings(address player_) external returns (uint256 amount_);

    /**
     * @notice Syncs winnings by calling migrateWinning on old contract.
     * @param oldViclette_ Address of the old Viclette contract.
     */
    function syncWinnings(address oldViclette_) external;

    /**
     * @notice Requests a random number for the current round.
     * @return requestId The identifier for the random number request.
     */
    function requestRandomNumber() external returns (uint256 requestId);

    /**
     * @notice Sets the VRF (Verifiable Random Function) contract address.
     * @param vrfContract_ The address of the VRF contract.
     */
    function setVRFContract(address vrfContract_) external;

    /**
     * @notice Sets the minimum betting amount.
     * @param minBetAmount_ Minimum amount for bets.
     */
    function setMinBetAmount(uint256 minBetAmount_) external;

    /**
     * @notice Sets the maximum amount allowed in the contract's bank.
     * @param maxAmountAllowedInBank_ Maximum amount allowed in the bank.
     */
    function setMaxAmountAllowedInBank(uint256 maxAmountAllowedInBank_) external;

    /**
     * @notice Sets the old Viclette contract addresses.
     * @param oldViclettes_ Address of the old Viclette contracts.
     */
    function setOldViclettes(address[] memory oldViclettes_) external;

    /**
     * @notice Retrieves the random number for the last request.
     * @return The random number.
     */
    function getRandomNumber() external view returns (uint256);

    /**
     * @notice Checks if the random number for the last request is ready.
     * @return True if the random number is ready, false otherwise.
     */
    function checkRequest() external view returns (bool);

    /**
     * @notice Provides the status of the contract including the next request timestamp,
     * contract balance, and player's winnings.
     * @return nextRequestTimestamp The timestamp for the next allowed request.
     * @return balance The contract's ether balance.
     * @return winnings The requesting player's winnings.
     */
    function getStatus() external view returns (uint256, uint256, uint256);

    /**
     * @notice Provides the bets placed by the requesting player.
     * @return bets The bets placed by the requesting player.
     */
    function getBets() external view returns (VicletteStorage.Bet[] memory);
}
