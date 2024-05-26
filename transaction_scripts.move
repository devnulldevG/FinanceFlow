module AssetManager {
    use std::signer;

    struct Asset {
        id: u64,
        name: vector<u8>,
        amount: u128,
    }

    struct AssetsHolder has key {
        assets: vector<Asset>,
    }

    public fun create_account(account: &signer) {
        let assets = vector<[]>;
        move_to(account, AssetsHolder { assets });
    }

    public fun create_asset(account: &signer, id: u64, name: vector<u8>, amount: u128) {
        let holder = borrow_global_mut<AssetsHolder>(signer::address_of(account));
        let asset = Asset { id, name, amount };
        vector::push_back(&mut holder.assets, asset);
    }

    public fun transfer_asset(from: &signer, to: address, asset_id: u64, amount: u128) acquires AssetsHolder {
        let from_holder = borrow_global_mut<AssetsHolder>(signer::address_of(from));
        let to_holder = borrow_global_mut<AssetsHolder>(to);

        let index = vector::index_of(&from_holder.assets, |asset| { asset.id == asset_id });
        if (index == None) { return; }

        let asset = vector::borrow_mut(&mut from_holder.assets, index.unwrap());
        assert!(asset.amount >= amount, 1);
        asset.amount = asset.amount - amount;

        let to_index = vector::index_of(&to_holder.assets, |asset| { asset.id == asset_id });
        if (to_index == None) {
            let new_asset = Asset { id: asset_id, name: asset.name.clone(), amount: amount };
            vector::push_back(&mut to_holder.assets, new_asset);
        } else {
            let to_asset = vector::borrow_mut(&mut to_holder.assets, to_index.unwrap());
            to_asset.amount = to_asset.amount + amount;
        }
    }

    public fun get_asset_balance(account: &signer, asset_id: u64): u128 acquires AssetsHolder {
        let holder = borrow_global<AssetsHolder>(signer::address_of(account));
        let index = vector::index_of(&holder.assets, |asset| { asset.id == asset_id });
        if (index == None) { return 0; }
        let asset = vector::borrow(&holder.assets, index.unwrap());
        asset.amount
    }
}