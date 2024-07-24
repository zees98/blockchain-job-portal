// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

contract Ownable {
    address public owner;
    constructor() {
        owner = msg.sender;
    }

    modifier isContractOwner() {
        require(owner == msg.sender);
        _;
    }
}
