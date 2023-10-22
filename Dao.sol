// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DAO {
    string public name;
    address public founder;
    uint256 public totalShares;
    uint256 public totalProposals;

    struct Member {
        uint256 shares;
        bool hasVoted;
        mapping(uint256 => bool) votedProposals;
    }

    struct Proposal {
        address creator;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        bool passed;
    }

    mapping(address => Member) public members;
    Proposal[] public proposals;

    constructor(string memory _name) {
        name = _name;
        founder = msg.sender;
        totalShares = 0;
        totalProposals = 0;
    }

    modifier onlyMember() {
        require(members[msg.sender].shares > 0, "Only members can call this function");
        _;
    }

    function addMember(address _member, uint256 _shares) public {
        require(msg.sender == founder, "Only the founder can add members");
        require(_member != address(0), "Invalid member address");
        require(_shares > 0, "Shares must be greater than zero");
        require(members[_member].shares == 0, "Member already exists");

        members[_member].shares = _shares;
        totalShares += _shares;
    }

    function createProposal(string memory _description) public onlyMember {
        require(bytes(_description).length > 0, "Description can't be empty");

        proposals.push(Proposal({
            creator: msg.sender,
            description: _description,
            votesFor: 0,
            votesAgainst: 0,
            passed: false
        }));
        totalProposals++;
    }

    function vote(uint256 _proposalId, bool _voteFor) public onlyMember {
        require(!members[msg.sender].hasVoted, "You have already voted for a proposal");
        require(_proposalId < totalProposals, "Invalid proposal ID");

        Member storage member = members[msg.sender];
        Proposal storage proposal = proposals[_proposalId];

        if (_voteFor) {
            proposal.votesFor += member.shares;
        } else {
            proposal.votesAgainst += member.shares;
        }

        member.votedProposals[_proposalId] = true;
        member.hasVoted = true;

        // Check if the proposal has passed
        if (proposal.votesFor > totalShares / 2) {
            proposal.passed = true;
        }
    }

    function executeProposal(uint256 _proposalId) public {
        require(_proposalId < totalProposals, "Invalid proposal ID");
        Proposal storage proposal = proposals[_proposalId];

        require(proposal.passed, "Proposal has not passed");
        require(msg.sender == proposal.creator, "Only the creator can execute the proposal");

        // Implement the logic to execute the proposal here

        // Mark the proposal as executed
        proposal.passed = false;
    }
}
