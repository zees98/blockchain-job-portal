// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "./Ownable.sol";

contract JobContract is Ownable {
    uint256 public jobCounter = 0;
    event JobEvent(address _address, uint256 jobId, string message);
    event ProposalEvent(
        address _address,
        uint256 jobId,
        string title,
        string message
    );

    enum JobStatus {
        pending,
        inProgress,
        completed
    }
    struct Job {
        uint256 id;
        address employer;
        string title;
        string description;
        address freelancer;
        uint256 price;
        JobStatus status;
        uint256 blockTime;
    }

    enum ProposalStatus {
        pending,
        rejected,
        accepted
    }
    struct Proposal {
        address freelancer;
        string description;
        uint256 time;
        ProposalStatus status;
    }

    mapping(address => mapping(uint256 => bool)) public deleteApproved;
    mapping(address => Job[]) public jobMap;
    mapping(address => mapping(uint256 => Proposal[])) public proposalMap;

    modifier isValidAmount(uint256 amount) {
        require(amount == msg.value, "Not enough amount sent for escrow");
        _;
    }
    modifier hasValidProposalFee() {
        require(msg.value == 10, "Please send 10 as proposal fee");
        _;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }

    function postJob(
        string memory title,
        string memory description,
        uint256 price
    ) public payable isValidAmount(price) {
        Job memory newJob = Job(
            jobCounter,
            msg.sender,
            title,
            description,
            address(0),
            price,
            JobStatus.pending,
            block.timestamp
        );
        jobMap[msg.sender].push(newJob);
        emit JobEvent(msg.sender, jobCounter, "New job Created");
        jobCounter++;
    }

    function requestJobDeletion(uint256 _id) public {
        Job memory job = jobMap[msg.sender][_id];
        require(job.employer == msg.sender, "You do not own the job.");
        require(
            job.status != JobStatus.completed,
            "Cannot delete completed Jobs."
        );
        deleteApproved[job.employer][_id] = false;

        emit JobEvent(msg.sender, jobCounter, "Job Deletion Requested");
    }

    function approveDelete(address employer, uint256 _id)
        public
        isContractOwner
    {
        deleteApproved[employer][_id] = true;
        delete jobMap[employer][_id];
    }

    function submitProposal(
        address employer,
        uint256 _id,
        string memory description
    ) public payable hasValidProposalFee {
      
        Job memory job = jobMap[employer][_id];
        require(
            job.employer != address(0),
            "This job doesnot exist"
        );
        require(job.status == JobStatus.pending, "This job is in progress or has been completed");

          Proposal memory proposal = Proposal(
            msg.sender,
            description,
            block.timestamp,
            ProposalStatus.pending
        );
        
        proposalMap[employer][_id].push(proposal);
        emit ProposalEvent(employer, _id, job.title, description);
    }
}
