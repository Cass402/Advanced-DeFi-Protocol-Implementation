/** This smart contract determines the borrowing and 
lending rates based on the utilization rates using a
linear model. */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract InterestRateModel {
    uint256 public baseRate; // the base rate if the utilization rate is 0
    uint256 public slope1; // the slope of the interest rate curve for the first segment
    uint256 public slope2; // the slope of the interest rate curve for the second segment
    uint256 public kink; // the utilization rate at which the interest rate curve kinks

    /** The constructor of the contract that takes in the base rate, slope1, slope2, and kink
        to set the parameters of the interest rate model.
    */
    constructor(uint256 _baseRate, uint256 _slope1, uint256 _slope2, uint256 _kink) {
        baseRate = _baseRate; // set the base rate
        slope1 = _slope1; // set the slope1
        slope2 = _slope2; // set the slope2
        kink = _kink; // set the kink
    }

    /** This function calculates the utilization rate.
    */
    function getUtilizationRate(uint256 totalBorrowed, uint256 totalSupply) public pure returns (uint256) {
        if (totalSupply == 0) { // check if the total supply is 0
            return 0; // return 0 utilization rate
        } else {
            return (totalBorrowed * 1e18) / totalSupply; // calculate the utilization rate
        }
    }

    /** This function calculates the borrow rate based on the utilization rate.
    */
    function getBorrowRate(uint256 totalBorrowed, uint256 totalSupply) public view returns (uint256) {
        uint256 utilizationRate = getUtilizationRate(totalBorrowed, totalSupply); // calculate the utilization rate
        if (utilizationRate < kink) { // check if the utilization rate is less than the kink
            return baseRate + (utilizationRate * slope1) / 1e18; // calculate the borrow rate for the first segment
        } else { // if the utilization rate is greater than or equal to the kink
            return baseRate + (kink * slope1) / 1e18 + ((utilizationRate - kink) * slope2) / 1e18; // calculate the borrow rate for the first and second segments
        }
    }

    /** This function calculates the supply rate based on the borrow rate.
    */
    function getSupplyRate(uint256 totalBorrowed, uint256 totalSupply) public view returns (uint256) {
        uint256 borrowRate = getBorrowRate(totalBorrowed, totalSupply); // calculate the borrow rate
        uint256 utilizationRate = getUtilizationRate(totalBorrowed, totalSupply); // calculate the utilization rate
        return (utilizationRate * borrowRate) / 1e18; // calculate the supply rate based on the borrow rate and utilization rate
    }
}