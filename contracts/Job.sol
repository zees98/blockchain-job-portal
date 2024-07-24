// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Ownable.sol";

contract JobContract is Ownable {
    uint public jobCounter = 0;

    struct Job {
        address employer;
        string title;
        string description;
        uint price;
    }

    mapping(address => Job[]) jobMap;

    function postJob(
        string memory title,
        string memory description,
        uint price
    ) public payable {
        Job memory newJob = Job(msg.sender, title, description, price);
        jobMap[msg.sender].push(newJob);
        jobCounter++;

    }
}
