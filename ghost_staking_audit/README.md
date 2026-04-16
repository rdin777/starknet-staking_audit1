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

🛡 Security Findings: [H-01] Gas Denial of Service via Unbounded Loop
Severity: High
Vulnerability Type: Denial of Service (DoS)

Description:
The GhostStaking contract contains an unbounded loop in the update_rewards function. This function iterates through all registered tokens in btc_tokens without any upper limit or pagination.

Impact:
An attacker can exploit the add_btc_token function (which lacks access control) to register a large number of dummy tokens. As the token count increases, the gas cost of calling update_rewards grows linearly. Eventually, the gas requirement will exceed the Starknet block gas limit, making it impossible for users to interact with the contract (e.g., claiming rewards or withdrawing funds).

Proof of Concept (PoC):
Execution of test_unbounded_iteration_gas_limit demonstrates:

Normal execution gas: ~13,840 L2 gas.

Exploited execution gas (500 tokens): ~8,047,846 L2 gas.

Recommendation:

Implement access control (Ownable) for token registration.

Use a "Pull" pattern for rewards or implement pagination for token iterations.
