# Starknet BTC Staking - Critical Vulnerability PoC

## Executive Summary
This repository contains proof and technical analysis of a critical logic bypass in the BTC Staking Attestation module.

## Vulnerability: Ghost Staking
The core issue lies in `Attestation.cairo` using public block hashes for validation.
- **Root Cause:** `get_block_hash_syscall` provides data available to any network participant.
- **Impact:** Attackers can claim 25% of rewards without BTC collateral and manipulate `MintingCurve` inflation.

## How to run the PoC
1. Install `snforge`.
2. Run: `snforge test test_ghost_stake_reward_extraction`
3. Result: The test will demonstrate rewards being allocated to a staker with zero BTC collateral.
