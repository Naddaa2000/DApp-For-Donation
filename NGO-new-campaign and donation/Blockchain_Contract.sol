// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract CharityCampaignFactory {
    address[] public deployedCampaigns;

    function createCampaign(string memory campaignName, uint256 totalAmount) public {
        address newCampaign = address(new CharityCampaign(campaignName, totalAmount));
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[] memory) {
        return deployedCampaigns;
    }
}

contract CharityCampaign {
    string public campaignName;
    uint256 public totalAmount;
    uint256 public currentDonations;
    bool public campaignComplete;
    address public owner;

    mapping(address => bool) public donors;

    event DonationMade(address indexed donor, string donorName, uint256 amount);
    event CampaignComplete(string campaignName, uint256 totalAmount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    constructor(string memory _campaignName, uint256 _totalAmount) {
        campaignName = _campaignName;
        totalAmount = _totalAmount;
        owner = msg.sender;
    }

    function makeDonation(string memory _donorName) public payable {
        require(msg.value > 0, "Donation amount must be greater than 0");
        require(bytes(_donorName).length > 0, "Donor name cannot be empty");
        require(!donors[msg.sender], "Donor has already donated to this campaign");
        require(!campaignComplete, "Campaign is already complete");

        currentDonations += msg.value;
        donors[msg.sender] = true;

        // Emit an event to log the donation
        emit DonationMade(msg.sender, _donorName, msg.value);

        // Check if the campaign donation goal is reached and mark the campaign as complete if so
        if (currentDonations >= totalAmount) {
            campaignComplete = true;
            emit CampaignComplete(campaignName, totalAmount);
        }
    }

    function withdrawFunds() public onlyOwner {
        require(campaignComplete, "Campaign is not yet complete");
        payable(owner).transfer(address(this).balance);
    }
}
