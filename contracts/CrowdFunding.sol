// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract CrowdFunding {
    mapping(address => uint256) public contributors; // address => contributor's who contributed for funding
    address public owner; // owner of the contract
    uint256 public fundingStart; // funding start
    uint256 public fundingEnd; // funding end
    uint256 public fundingCurrent; // current funding
    uint256 public fundingTarget; // funding target
    uint256 public minFunding; // minimum funding
    uint256 public maxFunding; // maximum funding
    uint256 public noOfContributors; // number of contributors

    /* struct for requests for the owner || manager */
    struct Request {
        uint256 amount; // amount of funding requested
        string description; // description of the request
        address payable to; // address of the recipient of the funds
        bool approved; // is the request approved
        uint256 noOfVoters; // number of voters
        mapping(address => bool) voters; // address => voter's who voted for the request
    }

    mapping(uint256 => Request) public requests; // uint => request
    uint256 public noOfRequests; // number of requests

    /* constructor */
    constructor(
        uint256 _fundingStart,
        uint256 _fundingEnd,
        uint256 _fundingTarget,
        uint256 _minFunding,
        uint256 _maxFunding
    ) {
        owner = msg.sender;
        fundingStart = _fundingStart;
        fundingEnd = _fundingEnd;
        fundingTarget = _fundingTarget;
        minFunding = _minFunding;
        maxFunding = _maxFunding;
    }

    /* function to check if the contract is open for funding */
    function isOpen() public view returns (bool) {
        return fundingStart <= block.timestamp && fundingEnd >= block.timestamp;
    }

    /* function to check if the contract is closed for funding */
    function isClosed() public view returns (bool) {
        return fundingEnd < block.timestamp;
    }

    /* function to check the current funding */
    function getCurrentFunding() public view returns (uint256) {
        return fundingCurrent;
    }

    // function to check the funding target */
    function getFundingTarget() public view returns (uint256) {
        return fundingTarget;
    }

    /* function to check the minimum funding */
    function getMinFunding() public view returns (uint256) {
        return minFunding;
    }

    /* function to check the maximum funding */
    function getMaxFunding() public view returns (uint256) {
        return maxFunding;
    }

    /* function to check the number of contributors */
    function getNoOfContributors() public view returns (uint256) {
        return noOfContributors;
    }

    /* function to send funds to the contract */
    function sendFunds() public payable {
        // check if the contract is open for funding
        require(isOpen(), "Funding is not open");

        // check if the amount is greater than the minimum funding amount and less than the maximum funding amount
        require(
            msg.value >= minFunding && msg.value <= maxFunding,
            "Amount is not within the range"
        );

        // check if contributor has not contributed
        if (contributors[msg.sender] == 0) {
            noOfContributors++;
        }

        // if contributors has contributed, add the amount to the current funding
        contributors[msg.sender] += msg.value;
        fundingCurrent += msg.value;
    }

    /* function to refund the contributor amount */
    function refund() public {
        // check if the contract is open for funding
        require(isOpen(), "Funding is not open");

        // check if the contributor has contributed
        require(
            contributors[msg.sender] > 0,
            "Contributor has not contributed"
        );

        // make the user address payable to refund the amount
        address payable user = payable(msg.sender);
        // refund the amount to the user from the contract
        user.transfer(contributors[msg.sender]);
        // remove the contributor from the contributors mapping
        contributors[msg.sender] = 0;
    }

    /* modifier to check if the sender is the owner or manager */
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    /* function to create a request by only the owner */
    function createRequest(
        string memory _description,
        address payable _to,
        uint256 _amount
    ) public payable onlyOwner {
        // check if the amount is greater than the funding target
        require(
            msg.value <= fundingTarget,
            "Amount is greater than the funding target"
        );

        // create a new request
        Request storage newRequest = requests[noOfRequests];

        // increment the number of requests
        noOfRequests++;

        // set the request values
        newRequest.amount = _amount;
        newRequest.description = _description;
        newRequest.to = _to;
        newRequest.approved = false;
        newRequest.noOfVoters = 0;
    }

    /* function to vote for a request by only by the contributors */
    function voteRequest(uint256 _requestNo) public {
        // check if owner has not voted for the request
        require(msg.sender != owner, "Onwer is not allowed to vote");

        // create a new request
        Request storage thisRequest = requests[_requestNo];

        // check if the request has not been approved
        require(!thisRequest.approved, "Request has already been approved");

        // check if the request has not been voted by the sender
        require(
            !thisRequest.voters[msg.sender],
            "You have already voted for this request"
        );

        // voted for the request
        thisRequest.voters[msg.sender] = true;
        thisRequest.noOfVoters++;
    }

    /* function to make a payment for a request by only the owner */
    function makePayment(uint256 _requestNo) public onlyOwner {
        // check if funding amount is greater than the target fund amount
        require(fundingCurrent >= fundingTarget, "Funding is not met");

        // create a new request
        Request storage thisRequest = requests[_requestNo];

        // check if the request has been approved
        require(!thisRequest.approved, "Request has been approved");

        // check if the majority of voters has voted for the request
        require(
            thisRequest.noOfVoters > (noOfContributors / 2),
            "Not enough voters"
        );

        // transfer the amount to the recipient
        thisRequest.to.transfer(thisRequest.amount);

        // set the request as approved
        thisRequest.approved = true;

        // remaining amount to be funded
        fundingCurrent -= thisRequest.amount;
    }
}
