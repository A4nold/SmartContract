# SmartContracts and solidity learning
First smart contract built on the ethereum block chain. its a simple contract which gives out a parents ETH to his kids once they are over a certain age
# Note
Turning this repo into my storage resource on my smart contract and solidity learning journey, second project added to this repo is the lottery smart contract.
This contract performs lottery functions, At the creation of this contract a subscription id must be passed as intializtion for a subscription id variable which
was used with chainlink VRF to generate a true random number which will be used in the formula to pick a winner, the owner of the contract is automatically added 
to the lottery and gets paid a comission when the winner is selected, the contract owner can also win the lottery as well (note in a true lottery system to keep 
things fair the owner should not take part). Only the owner can select a winner and the winner is ready to be picked when number of players is greater than or equals 
to three.
