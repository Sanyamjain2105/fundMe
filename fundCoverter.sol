// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";


library fundCoverter{
// declaring a library(stateless helper fnction)
//note a livrary can never have state varibles only internal variables hence we had to define 
// constructor and datafeed in contract and pass it to library to use it
   
    function getChainlinkDataFeedLatestAnswer(AggregatorV3Interface dataFeed) public view returns (uint256) {
        (
            /* uint80 roundId */,
            int256 answer,
            /*uint256 startedAt*/,
            /*uint256 updatedAt*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();

        //price of eth in terms of usd will be of form 200000000(1e8)
        // no decimal becuase solidity does not work well with decimals
        //now remember we used eth in terms of 1e18 wei
        //so we need to convert in form of uint and in 1e18 terms
        return uint256(answer*1e10);
    }

    function getConversion(uint256 ethAmount,AggregatorV3Interface dataFeed) public view returns(uint256){
        uint256 ethRate=getChainlinkDataFeedLatestAnswer(dataFeed);
        // we devide by 1e18 because both are in terms of 1e18 result be 1e36 to bring back the result in
        // 1e18 format we devide by 1e18
        return (ethAmount*ethRate)/1e18;
    }
}