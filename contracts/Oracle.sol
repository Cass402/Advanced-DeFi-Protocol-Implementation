/** This smart contract will be used to get real-time price feeds
for the collaterals. It uses the ChainLink oracle for the price feeds
of the token to get real-time price values. */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Importing the necessary libraries
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol"; // ChainLink interface for the price feeds

// Oracle contract
contract Oracle {
    // Mapping to store the price feeds of the tokens
    mapping(address => AggregatorV3Interface) public priceFeeds;

    address public owner; // Owner of the contract

    // Modifier to check if the caller is the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Constructor to set the owner of the contract and the price feeds of the tokens
    constructor() {
        owner = msg.sender; // Set the owner of the contract
        // the price feed for ETH/USD
        //priceFeeds[0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE] = AggregatorV3Interface(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
    }

    // Function to add a new price feed for a token
    function addPriceFeed(address token, address feed) external onlyOwner {
        priceFeeds[token] = AggregatorV3Interface(feed);
    }

    // Function to get the latest price of a token
    function getLatestPrice(address token) public view returns (uint256) {
        require(address(priceFeeds[token]) != address(0), "Price feed not found"); // Check if the price feed exists
        (, int price, , ,) = priceFeeds[token].latestRoundData();
        require(price > 0, "Invalid price"); // Check if the price is valid
        return uint256(price * 10 ** 10); // Return the price
    }

    // Function to get the collateral value of a token
    function getCollateralValue(address token, uint256 collateralAmount) public view returns (uint256) {
        uint256 price = getLatestPrice(token); // Get the latest price of the token
        return price * collateralAmount; // Calculate the collateral value and return it
    }

    
}