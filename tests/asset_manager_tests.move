address 0x1 {
module AssetManager {
    use 0x1::Signer;
    use 0x1::Errors;
    use 0x1::Vector;

    const E_ASSET_ALREADY_EXISTS: u64 = 101;
    const E_TRANSFER_FAILED: u64 = 102;
    const E_INSUFFICIENT_QUANTITY: u64 = 103;
    const E_ASSET_NOT_FOUND: u64 = 104;

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

        assert(!Vector::contains_key(&mut borrow_global_mut<Asset>(issuer).info.name, &name), E_ASSET_ALREADY_EXISTS);

        let asset_info = AssetInfo {
            name,
            issuer,
        };

        let asset = Asset {
            info: asset_info,
            quantity: initial_quantity,
        };

        move_to(account, asset);
    }

    public fun check_and_transfer_asset(from: &Signer, to: &Signer, name: vector<u8>, quantity: u64) acquires Asset {
        let sender_address = Signer::address_of(from);
        let receiver_address = Signer::address_of(to);

        let sender_asset = borrow_global_mut<Asset>(sender_address);
        assert(Vector::contains_key(&sender_asset.info.name, &name), E_ASSET_NOT_FOUND);
        assert(sender_asset.quantity >= quantity, E_INSUFFICIENT_QUANTITY);

        let receiver_asset = borrow_global_mut<Asset>(receiver_address);
        assert(Vector::contains_key(&receiver_asset.info.name, &name), E_ASSET_NOT_FOUND);

        sender_asset.quantity -= quantity;
        receiver_asset.quantity += quantity;
    }

    public fun transfer_asset(from: &Signer, to: address, quantity: u64) acquires Asset {
    }
}

module Errors {
    public fun abort_code(code: u64) {
        abort code;
    }
}

module TestFramework {
    use 0x1::Signer;
    use 0x1::AssetManager::Asset;
    use 0x1::Vector;

    public fun assert<T: copy + drop + store>(b: bool, err: T) {
        if (!b) {
            abort 0x1;
        }
    }

    public fun test_create_and_transfer_asset() {
        let alice = Signer::new();
        let bob = Signer::new();
        let gold_name = b"Gold".to_vec();
        AssetManager::create_asset(&alice, gold_name, 100);
        AssetManager::check_and_transfer_asset(&alice, &bob, gold_name, 50);
    }

    public fun run_tests() {
        test_create_and_transfer_asset();
    }
}

script {
    use 0x1::TestFramework;

    fun main() {
        TestFramework::run_tests();
    }
}