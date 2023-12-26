// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Ownable} from "./abstracts/Ownable.sol";

import {IVRFService} from "./interfaces/IVRFService.sol";
import {IViclette} from "./interfaces/IViclette.sol";

import {VicletteStorage} from "./VicletteStorage.sol";

/**
 * @title Viclette Betting Game Contract
 * @dev Implements the betting logic for the Viclette game, inheriting from VicletteStorage and Ownable.
 * This contract manages bet placement, random number generation, winnings calculation, and ether management.
 */
contract Viclette is VicletteStorage, IViclette, Ownable {
    IVRFService public vrfContract;

    modifier onlyNewViclette() {
        require(msg.sender == newViclette, "not new viclette");
        _;
    }

    /**
     * @dev Constructor sets up the initial contract state.
     * @param vrfContract_ Address of the VRF contract.
     */
    constructor(address vrfContract_) {
        vrfContract = IVRFService(vrfContract_);
        nextRequestTimestamp = block.timestamp;
        payouts = [2, 3, 3, 2, 2, 36];
        numberRange = [1, 2, 2, 1, 1, 37];
        minBetAmount = 0.0001 ether;
        maxAmountAllowedInBank = 0.01 ether;
    }

    /*//////////////////////////////////////////////////////////////////////////
                        EXTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Allows the contract to receive Ether.
     */
    function addEther() external payable {}

    /**
     * @dev Places bets for the current round.
     * @param bets_ Array of bet structs for the round.
     * @notice Requires the total bet amount to equal the message value.
     */
    function bet(Bet[] memory bets_) external payable {
        require(!paused, "contract is paused");
        require(!requested, "already request random number in this round");
        require(bets_.length > 0, "no bets");
        uint256 totalBetAmount = 0;
        for (uint256 i = 0; i < bets_.length; ++i) {
            Bet memory b = bets_[i];
            require(b.amount >= minBetAmount, "below min bet amount");
            require(b.betType >= 0 && b.betType <= 5, "bet type is not allowed");
            require(b.number >= 0 && b.number <= numberRange[b.betType], "number range is not allowed");
            totalBetAmount += b.amount;
            if (i == bets_.length - 1) {
                // last bet
                require(msg.value == totalBetAmount, "total bet amount not equal to msg.value");
            }
            /* we are good to go */
            _bets.push(Bet({player: b.player, betType: b.betType, number: b.number, amount: b.amount}));
            emit BetPlaced(b.player, b.betType, b.number, b.amount);
        }
    }

    /**
     * @dev Spins the wheel to determine winning bets.
     * @notice Requires a random number request to have been made and ready.
     */
    function spinWheel() external {
        require(requested, "no request for this round");
        require(_checkRequest(), "lastest random number not ready");
        uint256 number = _getRandomNumber() % 38;
        requested = false;

        // if someone has bet in this round, check if they won
        if (_bets.length != 0) {
            /* check every bet for this number */
            _calculateWinnings(number);
            /* delete all _bets */
            delete _bets;
        }
        /* check if to much money in the bank */
        if (address(this).balance > maxAmountAllowedInBank) _takeProfits();
        emit RandomNumber(number);
    }

    /**
     * @dev Allows players to cash out their winnings.
     * @notice Requires the player to have winnings available.
     */
    function cashOut() external {
        uint256 amount = _min(winnings[msg.sender], address(this).balance);
        address payable player = payable(msg.sender);
        require(amount > 0, "no winnings");
        // effect
        winnings[player] -= amount;
        (bool success,) = player.call{value: amount}("");
        require(success, "transfer failed");

        emit CashOut(player, amount);
    }

    /**
     * @dev Returns bets if the random number request is not ready.
     * @notice Only callable by the contract owner.
     */
    function returnBets() external onlyOwner {
        require(!_checkRequest() && requested, "random number is ready");
        for (uint256 i = 0; i < _bets.length; ++i) {
            Bet memory b = _bets[i];
            winnings[b.player] += b.amount;
        }
        delete _bets;
        requested = false;
        emit BetReturned(lastRequestId);
    }

    /**
     * @dev Migrates the contract to a new Viclette contract.
     * @param newVicette_ Address of the new Viclette contract.
     * @notice Only callable by the contract owner.
     */
    function migrateToNewViclette(address newVicette_) external onlyOwner {
        require(_bets.length == 0, "bets not empty");
        newViclette = newVicette_;
        paused = true;
        emit Migrated(newVicette_);
    }

    /**
     * @dev Syncs the player's winnings to the new Viclette contract.
     * @param player_ Address of the player.
     * @return amount_ The amount of winnings to sync.
     * @notice Only callable by the new Viclette contract.
     */
    function migrateWinnings(address player_) external onlyNewViclette returns (uint256 amount_) {
        require(paused, "contract is not paused");
        require(winnings[player_] > 0, "no winnings");
        amount_ = winnings[player_];
        winnings[player_] = 0;
        emit WinningsMigrated(player_, amount_);
    }

    /**
     * @dev Syncs winnings by calling migrateWinning on old contract.
     * @param oldViclette_ Address of the old Viclette contract.
     */
    function syncWinnings(address oldViclette_) external {
        require(isOldViclette[oldViclette_], "not old viclette");
        uint256 beforeAmount_ = winnings[msg.sender];
        uint256 migrateAmount = IViclette(oldViclette_).migrateWinnings(msg.sender);
        winnings[msg.sender] += migrateAmount;
        require(winnings[msg.sender] == beforeAmount_ + migrateAmount, "sync winning failed");
        emit WinningsSynced(msg.sender, migrateAmount);
    }

    /**
     * @dev Requests a random number for the current round.
     * @return requestId The identifier for the random number request.
     * @notice Ensures that no previous request is pending and the request cooldown has passed.
     */
    function requestRandomNumber() external returns (uint256 requestId) {
        require(!paused, "contract is paused");
        require(!requested, "already request random number in this round");
        require(block.timestamp >= nextRequestTimestamp, "not allowed to request yet");
        nextRequestTimestamp = block.timestamp + 90 seconds;

        requestId = _computeRequestId(msg.sender, nonce);
        string memory seed = _computeSeed(requestId, nonce);
        vrfContract.requestRandomness(requestId, seed);

        nonce++;
        lastRequestId = requestId;
        requested = true;
        emit RequestSent(requestId, seed);
    }

    /**
     * @dev Sets the VRF (Verifiable Random Function) contract address.
     * @param vrfContract_ The address of the VRF contract.
     * @notice Only callable by the contract owner.
     */
    function setVRFContract(address vrfContract_) external onlyOwner {
        require(vrfContract_ != address(0), "zero address not allowed");
        vrfContract = IVRFService(vrfContract_);
        requested = false;
        emit VRFContractSet(vrfContract_);
    }

    /**
     * @dev Sets the minimum betting amount.
     * @param minBetAmount_ Minimum amount for bets.
     * @notice Only callable by the contract owner.
     */
    function setMinBetAmount(uint256 minBetAmount_) external onlyOwner {
        require(minBetAmount_ >= 0, "min bet amount must be positive");
        minBetAmount = minBetAmount_;
        emit MinBetAmountSet(minBetAmount_);
    }

    /**
     * @dev Sets the maximum amount allowed in the contract's bank.
     * @param maxAmountAllowedInBank_ Maximum amount allowed in the bank.
     * @notice Only callable by the contract owner.
     */
    function setMaxAmountAllowedInBank(uint256 maxAmountAllowedInBank_) external onlyOwner {
        require(maxAmountAllowedInBank_ >= 0, "max amount allowed in the bank must be positive");
        maxAmountAllowedInBank = maxAmountAllowedInBank_;
        emit MaxAmountAllowedInBankSet(maxAmountAllowedInBank_);
    }

    /**
     * @dev Sets old Viclette contracts.
     * @param oldViclettes_ Addresses of old Viclette contracts.
     * @notice Only callable by the contract owner.
     */
    function setOldViclettes(address[] memory oldViclettes_) external onlyOwner {
        for (uint256 i = 0; i < oldViclettes_.length; ++i) {
            isOldViclette[oldViclettes_[i]] = true;
        }
        emit OldViclettesSet(oldViclettes_);
    }

    /*//////////////////////////////////////////////////////////////////////////
                            EXTERNAL CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /**
     * @dev Retrieves the random number for the last request.
     * @return The random number.
     * @notice Requires the random number to be ready.
     */
    function getRandomNumber() external view returns (uint256) {
        return _getRandomNumber();
    }

    /**
     * @dev Checks if the random number for the last request is ready.
     * @return True if the random number is ready, false otherwise.
     */
    function checkRequest() external view returns (bool) {
        return _checkRequest();
    }

    /**
     * @dev Provides the status of the contract including the next request timestamp,
     * contract balance, and player's winnings.
     * @return nextRequestTimestamp The timestamp for the next allowed request.
     * @return balance The contract's ether balance.
     * @return winnings The requesting player's winnings.
     */
    function getStatus() external view returns (uint256, uint256, uint256) {
        return (
            nextRequestTimestamp, // when can we request random number again
            address(this).balance, // roulette balance
            winnings[msg.sender] // winnings of player
        );
    }

    /**
     * @dev Provides the bets placed by the requesting player.
     * @return bets The bets placed by the requesting player.
     */
    function getBets() external view returns (Bet[] memory) {
        Bet[] memory bets = new Bet[](_bets.length);
        uint256 index = 0;
        for (uint256 i = 0; i < _bets.length; ++i) {
            if (_bets[i].player == msg.sender) {
                bets[index] = _bets[i];
                index++;
            }
        }
        return bets;
    }

    /*//////////////////////////////////////////////////////////////////////////
                            INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    function _getRandomNumber() internal view returns (uint256) {
        require(_checkRequest(), "random number not ready");
        return vrfContract.getRandomNumber(lastRequestId);
    }

    function _checkRequest() internal view returns (bool) {
        return vrfContract.checkRequest(lastRequestId);
    }

    function _takeProfits() internal {
        uint256 amount = address(this).balance - maxAmountAllowedInBank;
        if (amount > 0) owner().transfer(amount);
        emit ProfitTaken(owner(), amount);
    }

    function _calculateWinnings(uint256 number_) internal {
        for (uint256 i = 0; i < _bets.length; ++i) {
            bool won = false;
            Bet memory b = _bets[i];
            if (number_ == 0) {
                won = (b.betType == 5 && b.number == 0); // bet on 0
            } else {
                if (b.betType == 5) {
                    won = (b.number == number_); // bet on number_
                } else if (b.betType == 4) {
                    if (b.number == 0) won = (number_ % 2 == 0); // bet on even
                    if (b.number == 1) won = (number_ % 2 == 1); // bet on odd
                } else if (b.betType == 3) {
                    if (b.number == 0) won = (number_ <= 18); // bet on low 18s
                    if (b.number == 1) won = (number_ >= 19); // bet on high 18s
                } else if (b.betType == 2) {
                    if (b.number == 0) won = (number_ <= 12); // bet on 1st dozen
                    if (b.number == 1) won = (number_ > 12 && number_ <= 24); // bet on 2nd dozen
                    if (b.number == 2) won = (number_ > 24); // bet on 3rd dozen
                } else if (b.betType == 1) {
                    if (b.number == 0) won = (number_ % 3 == 1); // bet on left column
                    if (b.number == 1) won = (number_ % 3 == 2); // bet on middle column
                    if (b.number == 2) won = (number_ % 3 == 0); // bet on right column
                } else if (b.betType == 0) {
                    if (b.number == 0) {
                        // bet on black
                        if (number_ <= 10 || (number_ >= 19 && number_ <= 28)) {
                            won = (number_ % 2 == 0);
                        } else {
                            won = (number_ % 2 == 1);
                        }
                    } else {
                        // bet on red
                        if (number_ <= 10 || (number_ >= 19 && number_ <= 28)) {
                            won = (number_ % 2 == 1);
                        } else {
                            won = (number_ % 2 == 0);
                        }
                    }
                }
            }
            /* if winning bet, add to player winnings balance */
            if (won) {
                winnings[b.player] += b.amount * payouts[b.betType];
            }
        }
    }

    function _min(uint256 a_, uint256 b_) internal pure returns (uint256 minimum_) {
        minimum_ = a_ < b_ ? a_ : b_;
    }

    function _computeRequestId(address sender_, uint64 nonce_) private pure returns (uint256) {
        return (uint256(keccak256(abi.encode(sender_, nonce_))));
    }

    function _computeSeed(uint256 requestId_, uint64 nonce_) private view returns (string memory) {
        return string(abi.encodePacked(requestId_, nonce_, block.timestamp, block.difficulty));
    }
}
