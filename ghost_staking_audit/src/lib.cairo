#[starknet::interface]
pub trait IGhostStaking<TContractState> {
    fn add_btc_token(ref self: TContractState, token: starknet::ContractAddress);
    fn update_rewards(ref self: TContractState);
}

#[starknet::contract]
mod GhostStaking {
    use starknet::ContractAddress;
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess, 
        StorageMapReadAccess, StorageMapWriteAccess
    };

    #[storage]
    struct Storage {
        btc_tokens: Map<u32, ContractAddress>,
        btc_tokens_count: u32,
        // Заменили LegacyMap на Map, как просил компилятор
        token_registered: Map<ContractAddress, bool>, 
    }

    #[abi(embed_v0)]
    impl GhostStakingImpl of super::IGhostStaking<ContractState> {
        fn add_btc_token(ref self: ContractState, token: ContractAddress) {
            let is_registered = self.token_registered.read(token);
            assert(!is_registered, 'Token already registered');

            let count = self.btc_tokens_count.read();
            self.btc_tokens.write(count, token);
            self.btc_tokens_count.write(count + 1);

            self.token_registered.write(token, true);
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
