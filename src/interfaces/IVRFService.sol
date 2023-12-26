// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract IVRFService {
    function requestRandomness(uint256 requestId, string memory seed) external {}

    function checkRequest(uint256 requestId) public view returns (bool) {}

    function getRandomNumber(uint256 requestId) external view returns (uint256) {}
}
