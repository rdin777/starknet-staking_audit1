#[starknet::interface]
pub trait IGhostStaking<TContractState> {
    fn add_btc_token(ref self: TContractState, token: core::starknet::ContractAddress);
    fn update_rewards(ref self: TContractState);
}

#[starknet::contract]
mod GhostStaking {
    use core::starknet::ContractAddress;
    use core::starknet::storage::{Map, StoragePointerReadAccess, StoragePointerWriteAccess};

    #[storage]
    struct Storage {
        btc_tokens: Map<u32, ContractAddress>,
        btc_tokens_count: u32,
    }

    #[abi(embed_v0)]
    impl GhostStakingImpl of super::IGhostStaking<ContractState> {
        fn add_btc_token(ref self: ContractState, token: ContractAddress) {
            let count = self.btc_tokens_count.read();
            self.btc_tokens.write(count, token);
            self.btc_tokens_count.write(count + 1);
        }

        fn update_rewards(ref self: ContractState) {
            let mut i: u32 = 0;
            let count = self.btc_tokens_count.read();
            
            while i < count {
                let _token = self.btc_tokens.read(i);
                i += 1;
            };
        }
    }
}
