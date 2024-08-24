// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CrowdFunding {
    // Campaign structure
    struct Campaign {
        string title;
        string ipfsHash; // Do this IPFS hash for description or other large files storage
        address payable benefactor;
        uint goal;
        uint deadline;
        uint amountRaised;
        bool ended;
    }

    // State variables
    uint public campaignCount = 0;
    mapping(uint => Campaign) public campaigns;
    address public owner;

    // Events
    event CampaignCreated(uint campaignId, string title, string ipfsHash, address benefactor, uint goal, uint deadline);
    event DonationReceived(uint campaignId, address donor, uint amount);
    event CampaignEnded(uint campaignId, uint amountRaised, bool goalMet);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "You are not the owner so gererehere joor");
        _;
    }

    modifier campaignExists(uint _campaignId) {
        require(_campaignId < campaignCount, "Campaign does not exist");
        _;
    }

    modifier campaignNotEnded(uint _campaignId) {
        require(!campaigns[_campaignId].ended, "Campaign already ended");
        _;
    }

    // Constructor
    constructor() {
        owner = msg.sender;
    }

    // Create a new campaign with IPFS hash
    function createCampaign(string memory _title, string memory _ipfsHash, address payable _benefactor, uint _goal, uint _duration) public {
        require(_goal > 0, "Goal should be greater than zero");

        uint deadline = block.timestamp + _duration;

        campaigns[campaignCount] = Campaign({
            title: _title,
            ipfsHash: _ipfsHash, // This will store the IPFS hash
            benefactor: _benefactor,
            goal: _goal,
            deadline: deadline,
            amountRaised: 0,
            ended: false
        });

        emit CampaignCreated(campaignCount, _title, _ipfsHash, _benefactor, _goal, deadline);
        campaignCount++;
    }

    // Donate to a campaign of choice
    function donateToCampaign(uint _campaignId) public payable campaignExists(_campaignId) campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp <= campaign.deadline, "Campaign deadline has passed");

        campaign.amountRaised += msg.value;

        emit DonationReceived(_campaignId, msg.sender, msg.value);
    }

    // To end a running campaign
    function endCampaign(uint _campaignId) public campaignExists(_campaignId) campaignNotEnded(_campaignId) {
        Campaign storage campaign = campaigns[_campaignId];
        require(block.timestamp > campaign.deadline, "Campaign is still ongoing");

        campaign.ended = true;
        emit CampaignEnded(_campaignId, campaign.amountRaised, campaign.amountRaised >= campaign.goal);

        (bool success, ) = campaign.benefactor.call{value: campaign.amountRaised}("");
        require(success, "Transfer to benefactor failed");
    }

    // Withdraw leftover funds (onlyOwner)
    function withdrawLeftoverFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }
}
