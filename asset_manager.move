use std::collections::HashMap;
use std::env;

pub struct Asset {
    name: String,
    total_supply: u64,
    frozen: bool,
}

pub struct AssetLedger {
    balances: HashMap<String, u64>,
}

impl AssetLedger {
    pub fn new() -> AssetLedger {
        AssetLedger {
            balances: HashMap::new(),
        }
    }

    pub fn issue_asset(&mut self, account: String, amount: u64) {
        let balance = self.balances.entry(account).or_insert(0);
        *balance += amount;
    }

    pub fn transfer_asset(&mut self, from_account: String, to_account: String, amount: u64) -> bool {
        let from_balance = self.balances.entry(from_account).or_default();
        if *from_balance >= amount {
            *from_balance -= amount;
            let to_balance = self.balances.entry(to_account).or_insert(0);
            *to_balance += amount;
            true
        } else {
            false
        }
    }

    pub fn query_balance(&self, account: &String) -> u64 {
        *self.balances.get(account).unwrap_or(&0)
    }
}

pub struct AssetManager {
    assets: HashMap<String, Asset>,
    ledgers: HashMap<String, AssetLedger>,
}

impl AssetManager {
    pub fn new() -> AssetManager {
        AssetManager {
            assets: HashMap::new(),
            ledgers: HashMap::new(),
        }
    }

    pub fn issue_new_asset(&mut self, name: String, total_supply: u64, account: String) {
        let asset = Asset {
            name: name.clone(),
            total_supply,
            frozen: false,
        };
        self.assets.insert(name.clone(), asset);
        let ledger = self.ledgers.entry(name).or_insert_with(AssetLedger::new);
        ledger.issue_asset(account, total_supply);
    }

    pub fn transfer_assets(&mut self, asset_name: String, from_account: String, to_account: String, amount: u64) -> bool {
        if let Some(asset) = self.assets.get(&asset_name) {
            if !asset.frozen {
                if let Some(ledger) = self.ledgers.get_mut(&asset_name) {
                    return ledger.transfer_asset(from_account, to_account, amount);
                }
            }
        }
        false
    }

    pub fn freeze_asset(&mut self, asset_name: String) {
        if let Some(asset) = self.assets.get_mut(&asset_name) {
            asset.frozen = true;
        }
    }

    pub fn thaw_asset(&mut self, asset_name: String) {
        if let Some(asset) = self.assets.get_mut(&asset_name) {
            asset.frozen = false;
        }
    }

    pub fn query_asset_balance(&self, asset_name: &String, account: &String) -> u64 {
        if let Some(ledger) = self.ledgers.get(asset_name) {
            ledger.query_balance(account)
        } else {
            0
        }
    }
}

fn main() {
    let mut asset_manager = AssetManager::new();

    asset_manager.issue_new_asset("Gold".to_string(), 1000, "Alice".to_string());
    asset_manager.transfer_assets("Gold".to_string(), "Alice".to_string(), "Bob".to_string(), 100);

    let alice_balance = asset_manager.query_asset_balance(&"Gold".to_string(), &"Alice".to_string());
    let bob_balance = asset_manager.query_asset_balance(&"Gold".to_string(), &"Bob".to_string());

    println!("Alice's Gold balance: {}", alice_balance);
    println!("Bob's Gold balance: {}", bob_balance);
}