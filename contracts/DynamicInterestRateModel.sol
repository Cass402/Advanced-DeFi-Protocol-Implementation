/** This smart contract is a more advanced interest rate model that implements a more real-like model. The features include:
  * Variable interest rates that fluctuates based on market conditions or a fixed rate for more predictable interest rates.
  * Interest rate tiers that change based on the utilization rate. low utilization (0-50%), moderate utilization (51-80%), and high utilization (81-100%).
  * Incorporating external economic indicators (like ETH price, global interest rates, etc.) to adjust the base rate dynamically.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;