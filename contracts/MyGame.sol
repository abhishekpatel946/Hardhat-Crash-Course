// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;

enum Level {
    Novice,
    Intermediate,
    Advanced
}

struct Player {
    address payable playerAddress;
    Level playerLevel;
    string playerFirstName;
    string playerLastName;
    uint256 createdAt;
}

contract MyGame {
    // Gaming amount and dealer
    uint256 public pot = 0;
    address payable public dealer;

    // Players array
    Player[] public playersInGame;

    // The list of players and their count
    mapping(address => Player) public players;
    uint256 public totalPlayers = 0;

    // constructor
    constructor() {
        // Set the dealer
        dealer = payable(msg.sender);
    }

    modifier onlyDealer() {
        require(msg.sender == dealer, "Only the dealer can do this");
        _;
    }

    // create a new player
    function createPlayer(
        string memory firstName,
        string memory lastName,
        Level level
    ) private {
        players[msg.sender] = Player({
            playerAddress: payable(msg.sender),
            playerLevel: level,
            playerFirstName: firstName,
            playerLastName: lastName,
            createdAt: block.timestamp
        });
    }

    // get the player level
    function getPlayerLevel(address playerAddress) public view returns (Level) {
        Player storage player = players[playerAddress];
        return player.playerLevel;
    }

    // get a player by the address
    function changePlayerLevel(address playerAddress) public {
        Player storage player = players[playerAddress];
        if (block.timestamp >= player.createdAt + 20) {
            player.playerLevel = Level.Novice;
        }
    }

    // player can join the join the game
    function joinGame(string memory firstName, string memory lastName)
        public
        payable
    {
        require(msg.value == 25 ether, "The joining fee is 25 ether"); // check the fee 25000000000000000000 wei
        if (dealer.send(msg.value)) {
            createPlayer(firstName, lastName, Level.Novice);
            totalPlayers += 1;
            pot += msg.value;
        }
    }

    // winner's get the prize
    function payOutWinners(address loser) public payable onlyDealer {
        require((msg.value == pot * (1 ether)), "The prize is not the pot");
        require(totalPlayers > 1, "There are no winners");

        // the amount each winners will get
        uint256 payoutPerPlayer = msg.value / (totalPlayers - 1);
        for (uint256 i = 0; i < playersInGame.length; i++) {
            address payable currentPlayer = playersInGame[i].playerAddress;
            // ignore the loser and not eligible for the payout
            if (currentPlayer != loser) {
                currentPlayer.transfer(payoutPerPlayer);
            }
        }
    }
}
