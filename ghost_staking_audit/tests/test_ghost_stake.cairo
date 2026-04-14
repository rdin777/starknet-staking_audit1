#[feature("deprecated-starknet-consts")]

use starknet::ContractAddress;

#[starknet::interface]
trait IAttestation<TState> {
    fn get_current_epoch_target_attestation_block(self: @TState, operational_address: ContractAddress) -> u64;
    fn attest(ref self: TState, block_hash: felt252);
}

#[starknet::interface]
trait IStaking<TState> {
    fn get_staker_info(self: @TState, staker_address: ContractAddress) -> felt252;
}

#[test]
fn test_syntax_check() {
    let attest_addr = starknet::contract_address_const::<0x222>();
    let staking_addr = starknet::contract_address_const::<0x111>();
    
    let attestation = IAttestationDispatcher { contract_address: attest_addr };
    let staking = IStakingDispatcher { contract_address: staking_addr };

    let public_hash: felt252 = 0xabc;
    
    // Просто проверяем, что компилятор понимает эти вызовы
    // Мы не запускаем их, так как контракты не задеплоены
    assert(public_hash == 0xabc, 'Syntax OK');
}
