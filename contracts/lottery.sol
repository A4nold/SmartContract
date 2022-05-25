//SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.5.0 <0.9.0;

import "@chainlink/contracts/src/v0.8/interfaces/LinkTokenInterface.sol";
import "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";


contract Lottery is VRFConsumerBaseV2 {
    VRFCoordinatorV2Interface COORDINATOR;
    LinkTokenInterface LINKTOKEN;

    //state variables

    // Your subscription ID.
    uint64 s_subscriptionId;

    // Rinkeby coordinator. For other networks,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    address vrfCoordinator = 0x6168499c0cFfCaCD319c818142124B7A15E857ab;

    // The gas lane to use, which specifies the maximum gas price to bump to.
    // For a list of available gas lanes on each network,
    // see https://docs.chain.link/docs/vrf-contracts/#configurations
    bytes32 keyHash = 0xd89b2bf150e3b9e13446986e571fb9cab24b13cea0a43ea20a6049a85cc807cc;

    // Depends on the number of requested values that you want sent to the
    // fulfillRandomWords() function. Storing each word costs about 20,000 gas
    uint32 callbackGasLimit = 100000;

    // The default is 3, but you can set this higher.
    uint16 requestConfirmations = 3;

    // For this example, retrieve 2 random values in one request.
    // Cannot exceed VRFCoordinatorV2.MAX_NUM_WORDS.
    uint32 numWords =  1;

    uint256[] public s_randomWords;
    uint256 public s_requestId;

    address payable[] public players; 
    address public manager;

    //Declaring constructor
    constructor(uint64 subscriptionId) VRFConsumerBaseV2(vrfCoordinator){

        //Initializes vrf coordinator
        COORDINATOR = VRFCoordinatorV2Interface(vrfCoordinator);
        //Initializes the admin to the address that deploy the contract
        manager = msg.sender;

        //Adding the manager to the lottery
        players.push(payable(manager));

        //initializing the subscription id
        s_subscriptionId = subscriptionId;
    }

    //function neccessary to enable contract receieve ETH.
    receive() external payable{
        require(msg.sender != manager, "Manager cannot Fund");//ensures manager cannot fund
        require(msg.value == 0.1 ether);//ensure only 0.1 ether can be added to lottery
        // puts the addresses that sends ETH into array
        players.push(payable(msg.sender)); 
    }

    //function to return the contract balance
    function getBalance() public onlyOwner view returns(uint) {
        return address(this).balance;
    }

    // Assumes the subscription is funded sufficiently.
    function requestRandomWords() external onlyOwner {
        // Will revert if subscription is not set and funded.
        s_requestId = COORDINATOR.requestRandomWords(
        keyHash,
        s_subscriptionId,
        requestConfirmations,
        callbackGasLimit,
        numWords
        );
    }


    function fulfillRandomWords(
        uint256, /* requestId */
        uint256[] memory randomWords
    ) internal override {
        s_randomWords = randomWords;
    }

    //function to return random number
    // function random() internal view returns(uint){
    //     return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, players.length)));
    // }

    function pickWinner() public {
        //Checks to ensure only the manager can send the balance and number of player must be greater than 3
        require(msg.sender == manager);
        require(players.length >= 3, "Number of player must be more than 3");

        //variable holding random word
        uint r = s_randomWords.length - 1;

        address payable winner;
        
        uint index = r % players.length;//computing the random index to pick winner
        winner = players[index];//winner

        uint commission = (getBalance() * 10) / 100;//calculates 10% of balance
        uint newBalance = (getBalance() * 90) / 100;//calculates 90% of balance
        
        payable(manager).transfer(commission);//paying commison to contract owner
        winner.transfer(newBalance);//paying balance to contract winner

        //resets the array to zero
        players = new address payable[](0);   
    }

    modifier onlyOwner() {
        require(msg.sender == manager);
        _;
    }
}