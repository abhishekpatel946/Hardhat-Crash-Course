// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

contract BlindAuction {
    // VARIABLES
    struct Bid {
        bytes32 blindedBid;
        uint256 deposit;
    }

    address payable public beneficiary;
    uint256 public biddingEnd;
    uint256 public revealEnd;
    bool public ended;

    mapping(address => Bid[]) public bids;

    address public highestBidder;
    uint256 public highestBid;

    mapping(address => uint256) pendingReturns;

    // EVENTS
    event AuctionEnded(address winner, uint256 hightestBid);

    // MODIFIERS
    modifier onlyBefore(uint256 _time) {
        require(block.timestamp < _time);
        _;
    }
    modifier onlyAfter(uint256 _time) {
        require(block.timestamp > _time);
        _;
    }

    // FUNCTIONS
    constructor(
        uint256 _bidingTime,
        uint256 _revealTime,
        address payable _beneficiary
    ) {
        beneficiary = _beneficiary;
        biddingEnd = block.timestamp + _bidingTime;
        revealEnd = biddingEnd + _revealTime;
    }

    function generateBlindBidBytes32(uint256 value, bool fake)
        public
        pure
        returns (bytes32)
    {
        return keccak256(abi.encodePacked(value, fake));
    }

    function bid(bytes32 _blindedBid) public payable onlyBefore(biddingEnd) {
        bids[msg.sender].push(
            Bid({blindedBid: _blindedBid, deposit: msg.value})
        );
    }

    function reveal(uint256[] memory _values, bool[] memory _fake)
        public
        onlyAfter(biddingEnd)
        onlyBefore(revealEnd)
    {
        uint256 length = bids[msg.sender].length;
        require(_values.length == length);
        require(_fake.length == length);

        for (uint256 i = 0; i < length; i++) {
            Bid storage bidToCheck = bids[msg.sender][i];
            (uint256 value, bool fake) = (_values[i], _fake[i]);
            if (
                bidToCheck.blindedBid !=
                keccak256(abi.encodePacked(value, fake))
            ) {
                continue;
            }
            if (!fake && bidToCheck.deposit >= value) {
                if (!placeBid(msg.sender, value)) {
                    payable(msg.sender).transfer(
                        bidToCheck.deposit * (1 ether)
                    );
                }
            }
            bidToCheck.blindedBid = bytes32(0);
        }
    }

    function auctionEnd() public payable onlyAfter(revealEnd) {
        require(!ended, "Auction has still open");
        emit AuctionEnded(highestBidder, highestBid);
        ended = true;
        beneficiary.transfer(highestBid);
    }

    function withdraw() public payable {
        uint256 amount = pendingReturns[msg.sender];
        if (amount > 0) {
            pendingReturns[msg.sender] = 0;
            payable(msg.sender).transfer(amount);
        }
    }

    function placeBid(address bidder, uint256 amount)
        internal
        returns (bool success)
    {
        if (amount <= highestBid) return false;
        if (highestBidder != address(0))
            pendingReturns[highestBidder] += highestBid;
        highestBidder = bidder;
        highestBid = amount;
        return true;
    }
}
