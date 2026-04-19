use starknet::ContractAddress;

// 1. Объявляем интерфейс, чтобы контракт можно было вызвать извне
#[starknet::interface]
pub trait IStakingMathV2<TContractState> {
    fn deposit(ref self: TContractState, amount: u256);
    fn update_rewards(ref self: TContractState);
    fn get_reward_per_token(self: @TContractState) -> u256;
}

#[starknet::contract]
mod StakingMathV2 {
    use starknet::{ContractAddress, get_block_timestamp, get_caller_address};
    use starknet::storage::{
        Map, StoragePointerReadAccess, StoragePointerWriteAccess,
        StorageMapReadAccess, StorageMapWriteAccess
    };

    #[storage]
    struct Storage {
        reward_rate: u256,
        reward_per_token_stored: u256,
        last_update_time: u64,
        total_supply: u256,
        balances: Map<ContractAddress, u256>,
    }

    #[constructor]
    fn constructor(ref self: ContractState, initial_rate: u256) {
        self.reward_rate.write(initial_rate);
        self.last_update_time.write(get_block_timestamp());
    }

    #[abi(embed_v0)]
    impl StakingMathV2Impl of super::IStakingMathV2<ContractState> {
        // Простая функция депозита для изменения total_supply
        fn deposit(ref self: ContractState, amount: u256) {
            let caller = get_caller_address();
            let current_balance = self.balances.read(caller);
            let current_supply = self.total_supply.read();

            self.balances.write(caller, current_balance + amount);
            self.total_supply.write(current_supply + amount);
            
            // Важно: в реальном контракте тут должен быть update_rewards,
            // но мы оставим так, чтобы баг было проще поймать в тестах.
        }

        fn update_rewards(ref self: ContractState) {
            let time = get_block_timestamp();
            let last_time = self.last_update_time.read();
            let supply = self.total_supply.read();

            if (supply > 0 && time > last_time) {
                let duration: u256 = (time - last_time).into();
                let rate = self.reward_rate.read();

                // ---------------------------------------------------------
                // КРИТИЧЕСКАЯ УЯЗВИМОСТЬ (БАГ №5):
                // Ошибка порядка операций (Division before Multiplication).
                // Сначала идет деление на supply, результат округляется до нуля, 
                // и только потом умножение на 10^18.
                // ---------------------------------------------------------
                let reward_increase = (duration * rate) / supply * 1_000_000_000_000_000_000;
                
                let current_stored = self.reward_per_token_stored.read();
                self.reward_per_token_stored.write(current_stored + reward_increase);
                self.last_update_time.write(time);
            }
        }

        fn get_reward_per_token(self: @ContractState) -> u256 {
            self.reward_per_token_stored.read()
        }
    }
#[cfg(test)]
mod tests {
    #[test]
    fn test_math_precision_loss() {
        // Тестируем ту самую логику: (duration * rate) / supply * precision
        let duration: u256 = 10;
        let rate: u256 = 1000;
        let supply: u256 = 1000000000000000000000000000; // 10^9 * 10^18 (огромный стейк)
        let precision: u256 = 1000000000000000000; // 10^18

        // Наша уязвимая формула из контракта
        let reward_increase = (duration * rate) / supply * precision;

        // Если результат 0 — значит баг существует и "съедает" награды
        assert(reward_increase == 0, 'BUG_CONFIRMED: Precision loss');
    }

    #[test]
    fn test_how_it_should_be() {
        let duration: u256 = 10;
        let rate: u256 = 1000;
        let supply: u256 = 1000000000000000000000000000;
        let precision: u256 = 1000000000000000000;

        // ПРАВИЛЬНАЯ формула: Сначала умножаем на precision, потом делим
        let reward_increase_correct = (duration * rate * precision) / supply;

        // Тут результат будет 10, награды не потеряны
        assert(reward_increase_correct > 0, 'Fixed formula should work');
    }
}
}
