Markdown

https://dev.to/rdin777/starknet-btc-staking-how-to-extract-rewards-with-zero-collateral-and-why-the-team-ignored-it-fo

# Starknet BTC Staking - Critical Vulnerability PoC 🛡️

## Executive Summary
Technical analysis and Proof-of-Concept (PoC) for a **Critical Logic Bypass** in the BTC Staking Attestation module. This vulnerability allows for reward extraction without actual BTC collateral.

> **Status:** Unpatched / Public Disclosure due to lack of technical engagement from the team.

---

## 🚨 The Vulnerability: Ghost Staking
The root cause is an insecure reliance on `get_block_hash_syscall` within `Attestation.cairo`. Since block hashes are public, any network participant can forge attestation data.

**Impact:**
* **Reward Theft:** Attackers can siphon up to 25% of rewards with zero BTC collateral.
* **Economic Manipulation:** Manipulation of the `MintingCurve` inflation metrics.

---

## 🛠️ Proof of Concept (PoC)
The vulnerability is verified through local simulation using `snforge` and `exploit.js`.

### 1. Cairo Integration Test
Demonstrates reward allocation to an empty staker address.
```bash
cd ghost_staking_audit
snforge test tests/test_ghost_stake.cairo
2. External Exploit Script
Simulates the attestation forgery logic.

Bash
node scripts/exploit.js
📅 Disclosure Timeline
March 21, 2026: Submitted report to the team. Dismissed as "AI slop".

March 22-24, 2026: Requested technical review; offered private PoC access. No response.

March 24, 2026: Public disclosure to protect user funds and ecosystem integrity.

Researcher: rdin777

## 🛡 Recent Audit Findings

### [H-01] Gas Denial of Service via Unbounded Loop
**Severity:** High
**Vulnerability Type:** Denial of Service (DoS)

**Description:**
The contract iterates through all registered tokens in a single transaction within the \`update_rewards\` function. There is no pagination or limit on the number of tokens.

**Impact:**
An attacker can bloat the token list by calling \`add_btc_token\`. As shown in the PoC, the gas cost increases linearly. With enough tokens, the transaction will exceed the **Starknet Block Gas Limit**, preventing any user from interacting with the rewards logic.

**PoC Results (starknet-foundry/snforge):**
- **Base state (1 token):** ~13,840 L2 gas
- **Attacked state (500 tokens):** ~8,047,846 L2 gas 🚀

---
*Research and PoC developed by rdin777*

---

## 🛠 Latest Updates (April 17, 2026)

### Fixed: Logic Vulnerability & Storage Inflation
During further auditing, a **Duplicate Token Registration** bug was identified. This allowed an attacker to register the same token multiple times, artificially inflating the loop size even with a single malicious contract.

**Changes implemented:**
- Added `token_registered: Map<ContractAddress, bool>` to track unique assets.
- Integrated `assert` validation in `add_btc_token` to prevent double-registration.
- Refactored imports to use modern `starknet` core library syntax.

### 📊 Security Verification Results
All tests passed successfully, confirming both the vulnerability and the fix:
1. `test_duplicate_token_registration`: **PASSED** (Confirmed: attempt to add duplicate now panics).
2. `test_unbounded_iteration_gas_limit`: **PASSED** (Confirmed: 500 unique tokens consume ~9.8M gas).

**Status:** The contract is now protected against internal redundancy attacks.


