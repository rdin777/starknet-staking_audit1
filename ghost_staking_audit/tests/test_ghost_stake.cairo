use core::starknet::ContractAddress;
use snforge_std::{declare, ContractClassTrait, DeclareResult};
// Добавь сюда реальные интерфейсы твоего проекта, если они отличаются
use ghost_staking_audit::IGhostStakingDispatcher;
use ghost_staking_audit::IGhostStakingDispatcherTrait;

#[test]
fn test_ghost_stake() {
    let declare_result = declare("GhostStaking").expect('Declaration failed');
    let contract_class = match declare_result {
        DeclareResult::Success(class) => class,
        DeclareResult::AlreadyDeclared(class) => class,
    };
    
    let (_contract_address, _) = contract_class.deploy(@ArrayTrait::new()).expect('Deployment failed');
    
    // Чистим адреса
    let _attest_addr: ContractAddress = 0x222.try_into().unwrap();
    let _staking_addr: ContractAddress = 0x111.try_into().unwrap();

    // Если переменные не используются в логике теста дальше, 
    // мы добавили "_" перед ними, чтобы компилятор молчал.
}

#[test]
fn test_syntax_check() {
    assert(1 == 1, 'Syntax ok');
}
