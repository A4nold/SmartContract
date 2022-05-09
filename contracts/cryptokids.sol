// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.7;

contract CryptoKids{
    // owner DAD
    address owner;

    event LogKidFundingReceived(address addr, uint amount, uint contractBalance);

    //assigning the value of the owner of the contract
    constructor(){
        owner = msg.sender;
    }

    // define Kid
    struct Kid{
        address payable walletAddress;
        string firstName;
        string lastName;
        uint releaseTime;
        uint amount;
        bool canWithdraw;
    }

    //array of type Kid to hold number of kids 
    Kid[] public kids;

    modifier onlyOwner(){
        require(msg.sender == owner, "Only the owner can add kids");
        _;
    }
    // add kids to contract
    function addKid(address payable walletAddress,string memory firstName,string memory lastName,uint releaseTime, uint amount,bool canWithdraw) public onlyOwner {
        
        kids.push(Kid(
            walletAddress,
            firstName,
            lastName,
            releaseTime,
            amount,
            canWithdraw
        ));
    }

    //This returns the balance value in the contract
    function balanceOf() public view returns(uint){
        return address(this).balance;
    }
    
    //deposit funds to contract, specifically to a kid's account
    function deposit(address walletAddress) payable public {
        addToKidsBalance(walletAddress);
    }

    function addToKidsBalance(address walletAddress) private{
        for(uint i = 0; i < kids.length; i++){
            if(kids[i].walletAddress == walletAddress){
                kids[i].amount += msg.value;
                emit LogKidFundingReceived(walletAddress, msg.value, balanceOf());
            }
        }
    }

    //getIndex function
    function getIndex(address walletAddress) view private returns(uint){
        for(uint i = 0; i < kids.length; i++){
            if(kids[i].walletAddress == walletAddress){
                return i;
            }
        }
        return 999;
    }

    // kid checks if able to withdraw
    function availableToWithdraw(address walletAddress) public returns(bool){
        uint index = getIndex(walletAddress);
        require(block.timestamp > kids[index].releaseTime, "You are not able to withdraw at this Time");
        if(block.timestamp > kids[index].releaseTime){
            kids[index].canWithdraw = true;
            return true;
        }else{
            return false;
        }
    }

    // withdraw money
    function withdraw(address payable walletAddress) payable public {
        uint i = getIndex(walletAddress);
        require(msg.sender == kids[i].walletAddress, "You must be the kid to withdraw");
        require(kids[i].canWithdraw == true, "You are not able to withdraw at this time");
        kids[i].walletAddress.transfer(kids[i].amount);
    }
}