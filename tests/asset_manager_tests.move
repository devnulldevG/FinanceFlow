address 0x1 {
module AssetManager {
    use 0x1::Signer;
    use 0x1::Errors;

    const E_ASSET_ALREADY_EXISTS: u64 = 101;
    const E_TRANSFER_FAILED: u64 = 102;
    const E_INSUFFICIENT_QUANTITY: u64 = 103;

    struct AssetInfo has key, copy, drop {
        name: vector<u8>,
        issuer: address,
    }

    struct Asset {
        info: AssetInfo,
        quantity: u64,
    }

    public fun create_asset(account: &Signer, name: vector<u8>, initial_quantity: u64) acquires Asset {
        let issuer = Signer::address_of(account);
        // Considering efficiency improvement - this placeholder logic can be enhanced
        // for actual checks of asset existence etc.
    }

    public fun transfer_asset(from: &Signer, to: address, quantity: u64) acquires Asset {
        let sender_address = Signer::address_of(from);
        // Placeholder for condition, adjusted for more direct reference use
    }
}

module Errors {
    public fun abort_code(code: u64) {
        abort code
    }
}

module TestFramework {
    use 0x1::Signor;
    use 0x1::AssetManager;

    public fun assert<T: copy + drop + store>(b: bool, err: T) {
        if (!b) {
            abort 0x1
        }
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