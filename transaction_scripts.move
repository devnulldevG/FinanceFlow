module AssetManager {
    use std::signer;
    use std::vector;

    struct Asset {
        id: u64,
        name: vector<u8>,
        amount: u128,
    }

    struct AssetsHolder has key {
        assets: vector<Asset>,
    }

    struct LogManager has key {
        logs: vector<vector<u8>>,
    }

    public fun create_account(account: &signer) {
        let empty_assets = vector[];
        move_to(account, AssetsHolder { assets: empty_assets });
        let empty_logs = vector[];
        move_to(account, LogManager { logs: empty_logs });
        
        log_operation(&signer::address_of(account), b"create_account");
    }

    public fun create_asset(account: &signer, id: u64, name: vector<u8>, amount: u128) {
        let assets_holder_ref = borrow_global_mut<AssetsHolder>(signer::address_of(account));
        let new_asset = Asset { id, name: name.clone(), amount };
        
        vector::push_back(&mut assets_holder_ref.assets, new_asset);
        
        log_operation(&signer::address_of(account), b"create_asset");
    }

    public fun transfer_asset(from_account: &signer, to_address: address, asset_id: u64, transfer_amount: u128) acquires AssetsHolder {
        let sender_assets_ref = borrow_global_mut<AssetsHolder>(signer::address_of(from_account));
        let receiver_assets_ref = borrow_global_mut<AssetsHolder>(to_address);

        let sender_asset_index = vector::index_of(&sender_assets_ref.assets, |asset| { asset.id == asset_id });
        if (sender_asset_index == None) { return; }

        let mut sender_asset_ref = vector::borrow_mut(&mut sender_assets_ref.assets, sender_asset_index.unwrap());
        assert!(sender_asset_ref.amount >= transfer_amount, 1);
        
        sender_asset_ref.amount -= transfer_amount;
        vector::remove(&mut sender_assets_ref.assets, sender_asset_index.unwrap());

        let receiver_asset_index = vector::index_of(&receiver_assets_ref.assets, |asset| { asset.id == asset_id });
        if (receiver_asset_index == None) {
            let transferred_asset = Asset { id: asset_id, name: sender_asset_ref.name.clone(), amount: transfer_amount };
            vector::push_back(&mut receiver_assets_ref.assets, transferred_asset);
        } else {
            let receiver_asset_ref = vector::borrow_mut(&mut receiver_assets_ref.assets, receiver_asset_index.unwrap());
            receiver_asset_ref.amount += transfer_amount;
        }
        
        log_operation(&signer::address_of(from_account), b"transfer_asset");
        log_operation(&to_address, b"receive_asset");
    }

    public fun get_asset_balance(account: &signer, asset_id: u64): u128 acquires AssetsHolder {
        let holder_ref = borrow_global<AssetsHolder>(signer::address_of(account));
        let asset_index = vector::index_of(&holder_ref.assets, |asset| { asset.id == asset_id });
        if (asset_index == None) { return 0; }
        
        let asset_ref = vector::borrow(&holder_ref.assets, asset_index.unwrap());
        
        log_operation(&signer::address_of(account), b"get_asset_balance");
        
        asset_ref.amount
    }
    
    private fun log_operation(account_addr: &address, operation_message: vector<u8>) acquires LogManager {
        let logs_ref = borrow_global_mut<LogManager>(*account_addr);
        vector::push_back(&mut logsise.logs, operation_message);
    }
}