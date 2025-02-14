// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;


contract RockPaperScissors {


    // ------------------------------------------------------ //
    //                Variables & Declarations                //
    // ------------------------------------------------------ //


    // Global constants
    uint256 public constant MIN_BET = 1;   // 0.01 ETH in wei

    // Global variables
    uint256 public betAmountPlayerA;                // playerA's bet amount
    uint256 public betAmountPlayerB;                // playerB's bet amount

    // Enums
    enum Moves {None, Rock, Paper, Scissors}        // None for init. Possible moves
    enum Outcomes {None, PlayerA, PlayerB, Draw}    // None for init. Possible outcomes

    // Player addresses
    address payable playerA;
    address payable playerB;

    // Encrypted player moves
    bytes32 private encMovePlayerA;
    bytes32 private encMovePlayerB;


    // ------------------------------------------------------ //
    //                   Function Modifiers                   //
    // ------------------------------------------------------ //


    //   >   ValidBet()
    //   -   Check if players bets are valid and within range
    // ---------------------------------------------------------
    modifier validBet() {

        require(msg.value >= MIN_BET, "Bet must at least be 0.01 ETH");
        
        // Validate bet against opponent
        if (betAmountPlayerA == 0) {
            betAmountPlayerA = msg.value;   // Set playerA's bet
        } else if (betAmountPlayerB == 0) {
            betAmountPlayerB = msg.value;   // Set playerA's bet
        } else {
            require(msg.value == betAmountPlayerA && msg.value == betAmountPlayerB,  "Bet must match playerA's bet");
        }
        _;

    }


    //   >   isAssigned()
    //   -   Check if players have been assigned
    // ---------------------------------------------------------
    modifier isAssigned() {

        require(msg.sender == playerA || msg.sender == playerB, "You are not part of the game");
        _;

    }


    //   >   hasPlayed()
    //   -   Check if both players have submitted their move
    // ---------------------------------------------------------
    modifier hasPlayed() {

        require(encMovePlayerA != bytes32(0) && encMovePlayerB != bytes32(0), "Both players must submit a move");
        _;

    }


    // ------------------------------------------------------ //
    //                       Functions                        //
    // ------------------------------------------------------ //


    //   >   join()
    //   -   Lets two players join the game
    // ---------------------------------------------------------
    function join() public payable validBet {

        require(playerA == address(0) || playerB == address(0), "Game is full (2/2)");
        require(msg.sender != playerA && msg.sender != playerB, "You are already part of the game");

        if (playerA == address(0)) {
            playerA = payable(msg.sender);  // Assign playerA
        } else {
            playerB = payable(msg.sender);  // Assign playerB
        }
    }


    // Event MoveSubmitted()
    event MoveSubmitted(address indexed _player, bytes32 _hashedMove, uint256 _salt);


    //   >   play()
    //   -   Lets the players play the game
    // ---------------------------------------------------------
    function play(Moves _move, uint256 _salt) public isAssigned hasPlayed {

        bytes32 hashedMove = hashMove(uint8(_move), _salt);

        if (msg.sender == playerA) {
            encMovePlayerA = hashedMove;    // Store playerA's move
        } else if (msg.sender == playerB) {
            encMovePlayerB = hashedMove;    // Store playerB's move
        }
    
        emit MoveSubmitted(msg.sender, hashedMove, _salt);

    }


    //   >   withdraw()
    //   -   Lets the winner withdraw the stake
    // ---------------------------------------------------------
    /*
    function withdraw() public {

    }
    */

    // ------------------------------------------------------ //
    //                    Helper Functions                    //
    // ------------------------------------------------------ //


    //   >   hashMove()
    //   -   Encrypts the players move
    // ---------------------------------------------------------
    function hashMove(uint8 _move, uint256 _salt) private pure returns(bytes32) {

        return keccak256(abi.encodePacked(_move, _salt));

    }
}


