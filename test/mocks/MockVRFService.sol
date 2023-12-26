// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

contract MockVRFService {
    function requestRandomness(uint256 requestId, string memory seed) external {}

    function checkRequest(uint256 requestId) public view returns (bool) {
        requestId; // silence unused variable warning
        // create a scenario to return true or false for testing purpose
        if (block.timestamp % 2 == 0) {
            return false;
        }
        return true;
    }

    function getRandomNumber(uint256 requestId) external pure returns (uint256) {
        requestId; // silence unused variable warning
        return 0;
    }
}
