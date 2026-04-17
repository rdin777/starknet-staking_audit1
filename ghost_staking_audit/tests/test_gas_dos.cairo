use core::starknet::ContractAddress;
use core::traits::TryInto;
use snforge_std::{declare, ContractClassTrait, DeclareResult};
use ghost_staking_audit::IGhostStakingDispatcher;
use ghost_staking_audit::IGhostStakingDispatcherTrait;

#[test]
fn test_unbounded_iteration_gas_limit() {
    let declare_result = declare("GhostStaking").expect('Declaration failed');
    
    let contract_class = match declare_result {
        DeclareResult::Success(class) => class,
        DeclareResult::AlreadyDeclared(class) => class,
    };
    
    let (contract_address, _) = contract_class.deploy(@ArrayTrait::new()).expect('Deployment failed');
    let dispatcher = IGhostStakingDispatcher { contract_address };

    let mut i: u32 = 0;
    while i < 500 {
        // Самый надежный способ конвертации для компилятора:
        let felt_val: felt252 = (i + 1).into();
        let unique_address: ContractAddress = felt_val.try_into().unwrap();
        
        dispatcher.add_btc_token(unique_address);
        i += 1;
    };

    dispatcher.update_rewards();
}
