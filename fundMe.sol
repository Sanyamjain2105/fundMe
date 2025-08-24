// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
// this is importing interface which gives us abi and allows us to call functions present in already deployed
// contracts directly from github @ sign tells remix that it needs to npm this module and then use the interface
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {fundCoverter} from "./fundCoverter.sol";

error notOwner();

contract fundMe{
    using fundCoverter for uint256;
    // attaches function of libraru to uint256 and call be called directly
    uint256 public constant minUsd=5;

    //using chainlink oracle interface 
    AggregatorV3Interface internal dataFeed;
    // initialising datafeed with address of the contract which we want to call
    // for our example we wanted eth to usd conversion to we used this address we may also change to other
    // address for other conversion rate also

    address public immutable owner;
    constructor() {
        dataFeed = AggregatorV3Interface(
            0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
        );
        owner=msg.sender;
    }
    address[] public funder;
    mapping(address=>uint256) public addressAmtfund;

    //payable keyword allows a function to accept native cryto of the blockchain
    // think of each contract as a wallet as well as code with which we can interact with 
    function fund() public payable {
        // allows user to send eth
        // we can set min eth required using require keyword

        require( msg.value.getConversion(dataFeed) >= minUsd, "Didnt send enough dough");
        // when calling library function the first param is the variable thorugh which we call function and
        // rest we pass as it 
        funder.push(msg.sender);
        addressAmtfund[msg.sender]+=msg.value;
    }

    function withdraw() public onlyOwner{
        
        //resetting map and array as we are withdrawing stuff
        uint totalFund=0;
        for(uint256 i=0;i<funder.length;i++){
            totalFund+=addressAmtfund[funder[i]];
            addressAmtfund[funder[i]]=0;
        }
        funder=new address[](0);// creating a new address array of size 0

        //1. transfer:
        //msg.sender of of type address but we need it to be of type apyable address to transfer fund so we typcast it
        //address(this).balance  returns current balance of the contract
        //payable(msg.sender).transfer(address(this).balance);
        // payable(msg.sender).transfer(totalFund);
        // with tranfer we can provide max gas to be used and if tranfer fails operation is reverted back

        //2. send:
        // we can also use call function which is low level function which allows us to send money to address
        // with send in case of failure transaction is not reverted back it returns a bool 
        // bool success=payable(msg.sender).send(address(this).balance);
        //in sent transaction is not automatically reverted in case of failure so to revert and get our fund back
        // we use require to revert back
        // require(success, "transaction failed");

        //3. call:
        (bool callsuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callsuccess, "Call failed");
    }

    modifier onlyOwner(){
        // require(msg.sender==owner, "Not the owner");

        if(msg.sender != owner){
            revert notOwner();
        }
        _;
    }
    receive() external payable { 
        fund();
    }

    fallback() external payable { 
        fund();
    }
}