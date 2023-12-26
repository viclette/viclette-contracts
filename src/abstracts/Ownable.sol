// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.17;

/**
 * @title Ownable
 * @dev This abstract contract provides basic authorization control functions, simplifying the implementation of "user permissions".
 */
abstract contract Ownable {
    // Variable to hold the owner's address
    address payable private _owner;

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
     */
    constructor() {
        _owner = payable(msg.sender);
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address payable) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a new owner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = payable(newOwner);
    }

    // Event to indicate ownership transfer
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
}
