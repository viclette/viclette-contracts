// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

import {Test, console2} from "forge-std/Test.sol";
import {Solarray} from "solarray/Solarray.sol";

import {IVicletteEvent} from "../src/interfaces/IVicletteEvent.sol";

import {MockViclette} from "./mocks/MockViclette.sol";
import {MockVRFService} from "./mocks/MockVRFService.sol";
import {VicletteStorage} from "../src/VicletteStorage.sol";

abstract contract BaseTest is Test, IVicletteEvent {
    MockViclette public viclette;
    MockVRFService public vrfService;

    address payable owner;
    address payable player;

    uint256 nowTimestamp;

    function setUp() public virtual {
        // create all the users
        owner = createUser("OWNER");
        player = createUser("PLAYER");

        // set the time
        nowTimestamp = block.timestamp;

        // deploy the contracts and add some ETH to it
        vm.startPrank(owner);
        vrfService = new MockVRFService();
        viclette = new MockViclette(address(vrfService));

        // add some ETH to the contract
        vm.deal({account: address(viclette), newBalance: 0.01 ether});

        // label the contract
        vm.label(address(viclette), "Viclette");

        // set player as the default msg.sender
        changePrank(player);
    }

    // helper functions
    function addWinnings(address player_, uint256 amount_) internal {
        viclette.addWinnings(player_, amount_);
    }

    function placeDefaultBets() internal {
        // place mutiple bets
        viclette.bet{value: 3 ether}(
            dynamicBets(
                Solarray.addresses(player, player, player), // addresses
                Solarray.uint8s(5, 5, 5), // betTypes
                Solarray.uint8s(0, 1, 2), // numbers
                Solarray.uint256s(1 ether, 1 ether, 1 ether) // amounts
            )
        );
    }

    function dynamicBets(
        address[] memory addresses,
        uint8[] memory betTypes,
        uint8[] memory numbers,
        uint256[] memory amounts
    ) internal pure returns (MockViclette.Bet[] memory bets_) {
        // make sure the arrays are the same length
        require(
            betTypes.length == numbers.length && betTypes.length == amounts.length && numbers.length == addresses.length,
            "Arrays must be the same length"
        );
        bets_ = new MockViclette.Bet[](betTypes.length);
        for (uint256 i = 0; i < betTypes.length; ++i) {
            bets_[i] = VicletteStorage.Bet(addresses[i], betTypes[i], numbers[i], amounts[i]);
        }
    }

    function createUser(string memory name) internal returns (address payable) {
        address payable user = payable(makeAddr(name));
        vm.deal({account: user, newBalance: 100 ether});
        return user;
    }
}
