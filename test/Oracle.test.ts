/** This typescript test files tests the Oracle.sol smart contract in the contracts folder
 * in the main directory. It tests the functions of the Oracle.sol smart contract.
 */

// Importing the necessary modules
import { ethers } from "hardhat";
import { expect } from "chai";
import { Oracle, MockV3Aggregator } from "../typechain-types";

describe("Oracle", function () {
  let oracle: Oracle;
  let owner: any;
  let mockPriceFeed: MockV3Aggregator;
  // Before hook to deploy the Oracle.sol smart contract and MockV3Aggregator.sol smart contract
  before(async function () {
    [owner] = await ethers.getSigners(); // Getting the owner of the contract
    const OracleFactory = await ethers.getContractFactory("Oracle"); // Getting the Oracle.sol smart contract factory
    const oracleInstance = (await OracleFactory.deploy()) as any; // Deploying the Oracle.sol smart contract
    //await oracleInstance.deployed(); // Waiting for the Oracle.sol smart contract to be deployed

    oracle = oracleInstance as Oracle; // Assigning the deployed Oracle.sol smart contract to the oracle variable
    // Deploying the MockV3Aggregator.sol smart contract
    const MockV3AggregatorFactory = await ethers.getContractFactory(
      "MockV3Aggregator"
    );
    const mockPriceFeedInstance = (await MockV3AggregatorFactory.deploy(
      ethers.parseUnits("3000", 8)
    )) as any;

    mockPriceFeed = mockPriceFeedInstance as MockV3Aggregator; // Assigning the deployed MockV3Aggregator.sol smart contract to the mockPriceFeed variable

    // Adding the price feed to the Oracle.sol smart contract
    await oracle.addPriceFeed(
      "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeee",
      mockPriceFeed.getAddress()
    );
  });

  // Test case to check the owner of the Oracle.sol smart contract
  it("Should return the owner of the contract", async function () {
    expect(await oracle.owner()).to.equal(owner.address); // Checking if the owner of the contract is the same as the owner of the contract
  });

  // Test case to check the addition of a new price feed
  it("Should add a new price feed", async function () {
    const tokenAddress = "0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599"; // WBTC
    const feedAddress = "0xdeb288f737066589598e9214e782fa5a8ed689e8"; // WBTC/USD price feed

    await oracle.addPriceFeed(tokenAddress, feedAddress); // Adding a new price feed
    expect((await oracle.priceFeeds(tokenAddress)).toLowerCase()).to.equal(
      feedAddress
    ); // Checking if the price feed was added successfully
  });

  // Test case to calculate collateral value correctly
  it("Should calculate the collateral value correctly", async function () {
    const tokenAddress = "0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeee"; // ETH
    const collateralAmount = ethers.parseEther("1"); // 1 ETH
    const collateralValue = await oracle.getCollateralValue(
      tokenAddress,
      collateralAmount
    ); // Calculating the collateral value

    console.log("Collateral Value: ", collateralValue.toString()); // Logging the collateral value
    expect(collateralValue).to.be.a("number"); // Checking if the collateral value is a number
  });
});
