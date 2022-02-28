// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract SimpleAuction {
    // Parameter of the auction
    address payable public beneficiary;
    uint256 public auctionEndTime;

    // Current state of the auctionEndTime
    address public highestBidder;
    uint256 public highestBid;

    // Bids or pendingReturns
    mapping(address => uint256) public pendingReturns;

    // to check if the auction is over
    bool ended = false;

    event HightBidIncrease(address bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    // Constructor
    constructor(uint256 _biddingTime, address payable _beneficiary) {
        beneficiary = _beneficiary;
        auctionEndTime = block.timestamp + _biddingTime;
    }

    // Bid on the auction
    function bid() public payable {
        if (block.timestamp >= auctionEndTime) {
            revert("The auction has already ended");
        }
        if (msg.value <= highestBid) {
            revert("You must bid higher than the current highest bid");
        }
        if (highestBid != 0) {
            pendingReturns[highestBidder] += highestBid;
        }

        highestBidder = msg.sender;
        highestBid = msg.value;
        emit HightBidIncrease(msg.sender, msg.value);
    }

    // Return the money to the winner
    function withdraw() public returns (bool) {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;

            if (!payable(msg.sender).send(amount)) {
                pendingReturns[msg.sender] = amount;
                return false;
            }
        }
        // If the sender has no pending returns, return true
        return true;
    }

    // End the auction
    function auctionEnd() public {
        if (block.timestamp < auctionEndTime) {
            revert("The auction has not yet ended");
        }
        if (ended) {
            revert("The auction has already ended");
        }

        // end the auction
        ended = true;
        emit AuctionEnded(highestBidder, highestBid);

        // send the money to the beneficiary
        beneficiary.transfer(highestBid);
    }
}
