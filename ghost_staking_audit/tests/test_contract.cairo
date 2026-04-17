use starknet::ContractAddress; // Используем напрямую, без core::
use snforge_std::{declare, ContractClassTrait, DeclareResultTrait};

// Импортируем из твоего реального пакета ghost_staking_audit
use ghost_staking_audit::{IGhostStakingDispatcher, IGhostStakingDispatcherTrait};

#[test]
#[should_panic(expected: ('Token already registered', ))]
fn test_duplicate_token_registration() {
    let contract = declare("GhostStaking").unwrap().contract_class();
    let (contract_address, _) = contract.deploy(@array![]).unwrap();
    
    // Теперь dispatcher будет знать о методе add_btc_token
    let dispatcher = IGhostStakingDispatcher { contract_address };

    let token_address: ContractAddress = 0x123.try_into().unwrap();

    dispatcher.add_btc_token(token_address);
    dispatcher.add_btc_token(token_address);
}
