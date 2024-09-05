/** This smart contract is heart of the protocol. It handles the core logic
such as deposits, loans, interest accrual, borrow.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "./InterestRateModel.sol";
import "./Oracle.sol";

// LendingPool contract
contract LendingPool {
    struct Collateral {
        address token; // address of the token
        uint256 amount; // amount of the token
    }
    mapping(address => uint256) public deposits; // a mapping of user deposits
    mapping(address => uint256) public loans; // a mapping of user loans
    mapping(address => Collateral[]) public collaterals; // a mapping of user collaterals

    uint256 public totalBorrowed; // total amount borrowed from the protocol
    uint256 public totalSupply; // total amount deposited in the protocol

    InterestRateModel public interestRateModel;  // InterestRateModel contract instance
    Oracle public oracle; // Oracle contract instance

    uint256 public collateralizationRatio = 150; // collateralization ratio in percentage (150%)
    uint256 public liquidatiionThreshold = 120; // liquidation threshold in percentage (120%)

    /** The constructor of the contract that takes in the addresses of the 
        interestRateModel and oracle contracts so that the contract can interact
        with them.
    */
    constructor(address _interestRateModel, address _oracle) {
        interestRateModel = InterestRateModel(_interestRateModel); // set the address of the interestRateModel contract
        oracle = Oracle(_oracle); // set the address of the oracle contract
    }

    /** This function allows users to deposit collaterals into the protocol. 
        It increases the collateral of the user by the amount sent.
    */
    function depositCollateral() external payable {
        collaterals[msg.sender].push(Collateral({
            token: address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE), // address of the token
            amount: msg.value // amount of the token
        }));
    }

    /** This function allows users to deposit funds into the protocol. 
        It increases the deposit of the user by the amount sent.
    */
    function deposit() external payable {
        deposits[msg.sender] += msg.value; // increase the deposit of the user
        totalSupply += msg.value; // increase the total supply of the protocol
    }

    /** This function allows users to borrow funds from the protocol. 
        It checks the collaterals of the user and handles the borrow.
    */
    function borrow(uint256 amount) external {
        require(amount > 0, "Invalid amount"); // check if the amount is greater than 0
        uint256 collateralValue = oracle.getCollateralValue(collaterals[msg.sender][0].token, collaterals[msg.sender][0].amount); // get the value of the collaterals
        uint256 maxBorrow = (collateralValue * 1e18) / collateralizationRatio; // calculate the maximum amount that can be borrowed

        require(amount <= maxBorrow, "Insufficient collateral"); // check if the amount is less than the maximum borrow amount

        uint256 borrowRate = interestRateModel.getBorrowRate(totalBorrowed, totalSupply); // get the borrow rate
        uint256 interest = (amount * borrowRate) / 1e18; // calculate the interest
        loans[msg.sender] += amount + interest; // increase the loan of the user
        totalBorrowed += amount; // increase the total borrowed amount
        payable(msg.sender).transfer(amount); // transfer the borrowed funds to the user
    }

    /** This function allows users to repay the borrowed funds to the protocol. 
        It decreases the loan of the user by the amount sent.
    */
    function repay(uint256 amount) external {
        require(amount > 0, "Invalid amount"); // check if the amount is greater than 0
        loans[msg.sender] -= amount; // decrease the loan of the user
        totalBorrowed -= amount; // decrease the total borrowed amount
    }

    /** This function allows users to withdraw their deposits from the protocol. 
        It decreases the deposit of the user by the amount sent.
    */
    function withdraw(uint256 amount) external {
        require(deposits[msg.sender] >= amount, "Insufficient funds"); // check if the user has enough funds to withdraw
        deposits[msg.sender] -= amount; // decrease the deposit of the user
        payable(msg.sender).transfer(amount); // transfer the funds to the user
        totalSupply -= amount; // decrease the total supply of the protocol
    }

    /** This function is for the liquidation. It allows the liquidator to pay the loan of a borrower
        to get the collateral at a discount */
    function liquidate(address borrower) external payable {
        uint256 collateralValue = oracle.getCollateralValue(collaterals[borrower][0].token, collaterals[borrower][0].amount); // get the value of the borrower's collateral
        uint256 maxBorrow = (collateralValue * 1e18) / collateralizationRatio; // calculate the maximum amount that can be borrowed
        uint256 currentLoan = loans[borrower]; // get the current loan of the borrower

        require((currentLoan * 1e18) / maxBorrow >= liquidatiionThreshold, "Cannot liquidate"); // check if the loan-to-value ratio is above the liquidation threshold

        // Liquadtor repays the borrower's loan in exchange for the borrower's collateral at a discount
        loans[borrower] = msg.value; // set the loan of the borrower to the amount sent by the liquidator
        totalBorrowed -= msg.value; // decrease the total borrowed amount

        uint256 collateralToTransfer = (msg.value * collateralValue) / currentLoan; // calculate the amount of collateral to transfer
        collaterals[borrower][0].amount -= collateralToTransfer; // decrease the collateral of the borrower
        payable(msg.sender).transfer(collateralToTransfer); // transfer the collateral to the liquidator
    }
}
