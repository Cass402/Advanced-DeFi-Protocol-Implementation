/** A mock contract for testing purposes. It is used to test the price feeds of the
    Oracle.sol contract and will be deployed in the Oracle.test.ts file.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// Create an mock interface of the AggregatorV3Interface
interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

// Create a mock contract of the AggregatorV3Interface
contract MockV3Aggregator is AggregatorV3Interface {
    int256 public answer; // Create a public variable to store the answer

    // Create a constructor that takes an int256 as an argument
    constructor(int256 _initialAnswer) {
        answer = _initialAnswer;
    }

    // Create a function that returns the address of the contract
    function getAddress() external view returns (address) {
        return address(this);
    }

    // Create a function that returns the latest round data
    function latestRoundData() external view override returns (
        uint80 roundId,
        int256 _answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    )  {
        return (0, answer, 0, 0, 0);
    }

    // Create a function that updates the answer
    function updateAnswer(int256 _answer) external {
        answer = _answer;
    }

}
