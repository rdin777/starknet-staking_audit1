## Detailed Findings

### 1. [CRITICAL] Ghost Staking via Public Block Hash Attestation
* **Component:** `Attestation.cairo`, `staking.cairo`
* **Description:** Use of `get_block_hash_syscall` allows spoofing BTC stakes using public Starknet data.
* **Impact:** Unauthorized STRK minting and manipulation of the global reward pool.

### 2. [HIGH] MintingCurve Manipulation & Hyper-inflation
* **Component:** `MintingCurve.cairo`
* **Description:** The inflation formula `C * sqrt(total_stake * total_supply)` is vulnerable to artificial inflation of `total_stake`.
* **Impact:** Sybil attacks on the staking protocol can lead to rapid STRK supply dilution.

### 3. [MEDIUM/HIGH] Gas Bomb / DoS in Reward Distribution
* **Component:** `staking.cairo` (loop over `btc_tokens`)
* **Description:** Unbounded iteration over a list of tokens during reward updates can lead to transactions exceeding the gas limit.
* **Impact:** Potential Denial of Service (DoS) for large stakers, preventing them from claiming rewards or updating state.

### 4. [LOW/MEDIUM] Precision Loss in Weight Calculations
* **Component:** `utils.cairo`
* **Description:** Fixed-point math errors and potential division-by-zero scenarios in weight rebalancing.
* **Impact:** Minor financial discrepancies and potential contract reverts under specific edge cases.
