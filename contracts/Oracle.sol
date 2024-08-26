/** This smart contract will be used to get real-time price feeds
for the collaterals. */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Oracle contract
contract Oracle {
    // Currently mocking the price feed
    // Assuming 1 ETH = 2000 USD for simplicity
    function getCollateralValue(uint256 collateralAmount) external pure returns (uint256) {
        return collateralAmount * 2000;
    }
}