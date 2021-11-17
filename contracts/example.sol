pragma solidity ^0.8.4;

contract example{
    address payable myAddress;

    // A constructor is needed of I am going to set the value of myAddress to the sender by default
    constructor(){
        // So by default the message sender is not payable hence the funnction
        myAddress = payable(msg.sender)
    }
}