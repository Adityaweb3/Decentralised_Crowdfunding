// SPDX-License-Identifier : MIT 

pragma solidity ^0.8.17 ; 

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./PriceConverter.sol"; 

error NotOwner() ;

// People can fund the contract.
// List of people and their donated amount is stored.
// Only the owner should be able to withdraw funds
// All donors' lists should be reset after withdrawal for that cause



contract CrowdFund {
     using PriceConverter for uint256;

    mapping(address => uint256) public addressToAmountFunded;
    address[] public funders;

    address public  i_owner; // variable owner is immutable 
    uint256 public constant MINIMUM_USD = 1000 * 10 ** 18;

    constructor() {
        i_owner = msg.sender;
    }


    function sendFund() public payable {
         // require(msg.value.getConversionRate() >= MINIMUM_USD, "Need More Ethers");
         require(PriceConverter.getConversionRate(msg.value) >= MINIMUM_USD, "Need More Ethers");

         addressToAmountFunded[msg.sender] += msg.value;
         funders.push(msg.sender);

    }
  
    // Using Goerli Testnetwork for deployment of our project  so 

    //Eth/USD price feed address on Goerli : 0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e 



    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(0xD4a33860578De61DBAbDc8BFdb98FD742fA7028e);
        return priceFeed.version();
    }

    // Only owner can withdraw the funds 

    modifier onlyOwner {
    
        if (msg.sender != i_owner) revert  NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        for (uint256 funderIndex=0; funderIndex < funders.length; funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }

    
    funders = new address[](0);

    (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

     fallback() external payable {
        sendFund();
    }

    receive() external payable {
        sendFund();
    }

}

