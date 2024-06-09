use move_lang::test_utils::*;
use move_core_types::account_address::AccountAddress;
use move_vm_runtime::move_vm::MoveVM;
use move_vm_types::gas_schedule::*;
use vm::file_format::CompiledModule;

address 0x1 {
module AssetManager {
    use 0x1::Signer;

    struct AssetInfo has key, copy, drop {
        name: vector<u8>,
        issuer: address,
    }

    struct Asset {
        info: AssetInfo,
        quantity: u64,
    }

    public fun create_asset(account: &signer, name: vector<u8>, initial_quantity: u64) {
    }

    public fun transfer_asset(from: &signer, to: address, quantity: u64) {
    }
}
}

module TestFramework {
    use 0x1::Signer;
    use 0x1::AssetManager;

    public fun assert<T: copy + drop + store>(b: bool, err: T) {
    }

    public fun test_create_asset() {
        let alice = Signer::new();
        AssetManager::create_asset(&alice, b"Gold".to_vec(), 100);
    }

    public fun test_transfer_asset() {
        let alice = Signer::new();
        let bob_address: address = 0x2;
        AssetManager::create_asset(&alice, b"Gold".to_vec(), 100);
        AssetManager::transfer_asset(&alice, bob_address, 50);
    }

    public fun run_tests() {
        test_create_asset();
        test_transfer_asset();
    }
}

script {
    use 0x1::TestFramework;

    fun main() {
        TestFramework::run_tests();
    }
}