# FundMe Smart Contract  

This project is a **Solidity smart contract** that allows users to fund the contract with ETH while ensuring a **minimum funding requirement in USD** using **Chainlink price feeds**. The contract also includes features for the contract owner to withdraw funds securely.  

---

## 📂 Project Structure  

- **FundMe.sol** → Main contract where users can fund and the owner can withdraw.  
- **fundConverter.sol** → Library used to fetch ETH/USD conversion rates from Chainlink and convert ETH values.  

---

## 🚀 Features  

1. **Minimum USD Funding Requirement**  
   - Users must send at least `$5` worth of ETH (configurable via `minUsd`).  
   - Conversion is handled by the `fundConverter` library using Chainlink price feed.  

2. **Owner-Only Withdrawals**  
   - Only the contract deployer (owner) can withdraw funds.  
   - Uses a custom error `notOwner()` for gas-efficient error handling.  

3. **Safe Withdrawal Methods**  
   Supports three withdrawal approaches:
   - **Transfer** (limited gas, auto-reverts on failure).  
   - **Send** (returns a bool, requires manual `require(success)`).  
   - **Call** (recommended, flexible gas forwarding, safe with `require`).  

   Final implementation uses **call**, which is the most reliable method.  

4. **Receive & Fallback Functions**  
   - `receive()` → Triggered when ETH is sent without data.  
   - `fallback()` → Triggered when ETH is sent with unknown function call or data.  
   - Both redirect to `fund()`.  

5. **Gas Optimizations**  
   - `constant` and `immutable` variables reduce storage access cost.  
   - Custom error instead of `require("message")` saves gas.  
   - `using for` pattern attaches library functions to `uint256` for cleaner code.  

---

## 🔧 How It Works  

### Funding  
1. User calls `fund()` or sends ETH directly.  
2. Contract checks if the value sent in ETH (converted to USD) is >= `minUsd`.  
3. If valid, sender’s address and contribution are recorded.  

### Withdrawing  
1. Only the owner can call `withdraw()`.  
2. The function resets all funders’ balances.  
3. Funds are sent to the owner using the `call` method.  

---
📊 Key Solidity Concepts Used

Library (fundConverter) → Gas-efficient, reusable helper functions.

Chainlink Oracles → Provides real-world ETH/USD price.

Modifiers (onlyOwner) → Restrict function access.

Custom Errors (notOwner) → Save gas over require strings.

receive() & fallback() → Ensure contract can receive ETH seamlessly.

Gas Optimization → constant, immutable, and using for.

🧪 Testing Scenarios

✅ Sending less than $5 worth of ETH → Transaction reverts.

✅ Sending ≥ $5 worth of ETH → Transaction succeeds.

✅ Non-owner tries withdraw() → Transaction reverts with notOwner().

✅ Owner calls withdraw() → All funds transferred successfully.

✅ Sending ETH directly (without calling fund()) → Still funds contract via receive()/fallback().

📌 Dependencies

Solidity v0.8.18

Chainlink Contracts (for price feed interface)
