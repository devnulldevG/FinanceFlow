use std::{collections::HashMap, fmt};

pub struct Asset {
    name: String,
    total_supply: u64,
    frozen: bool,
}

pub struct AssetLedger {
    balances: HashMap<String, u64>,
}

pub struct AssetTransferLog {
    pub from: String,
    pub to: String,
    pub amount: u64,
    pub asset_name: String,
}

impl fmt::Display for AssetTransferLog {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        write!(f, "AssetTransfer -> From: {}, To: {}, Amount: {}, Asset: {}", self.from, self.to, self.amount, self.asset_name)
    }
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

    pub fn transfer_asset(&mut self, from_account: String, to_account: String, amount: u64, asset_name: &str) -> Result<AssetTransferLog, &'static str> {
        if self.has_sufficient_balance(&from_account, amount) {
            self.decrease_balance(&from_account, amount);
            self.increase_balance(&to_account, amount);

            Ok(AssetTransferLog {
                from: from_account,
                to: to_account,
                amount,
                asset_name: asset_name.to_string(),
            })
        } else {
            Err("Insufficient balance for the transaction.")
        }
    }

    pub fn query_balance(&self, account: &String) -> u64 {
        *self.balances.get(account).unwrap_or(&0)
    }

    fn has_sufficient_balance(&self, account: &String, amount: u64) -> bool {
        *self.balances.get(account).unwrap_or(&0) >= amount
    }

    fn decrease_balance(&mut self, account: &String, amount: u64) {
        let balance = self.balances.get_mut(account).unwrap();
        *balance -= amount;
    }

    fn increase_balance(&mut self, account: &String, amount: u64) {
        let balance = self.balances.entry(account.clone()).or_insert(0);
        *balance += amount;
    }
}

pub struct AssetManager {
    assets: HashMap<String, Asset>,
    ledgers: HashMap<String, AssetLedger>,
    transaction_logs: Vec<AssetTransferLog>,
}

impl AssetManager {
    pub fn new() -> AssetManager {
        AssetManager {
            assets: HashMap::new(),
            ledgers: HashMap::new(),
            transaction_logs: Vec::new(),
        }
    }

    pub fn issue_new_asset(&mut self, name: String, total_supply: u64, account: String) {
        self.create_and_store_asset(name.clone(), total_supply);
        let ledger = self.ledgers.entry(name).or_insert_with(AssetLedger::new);
        ledger.issue_asset(account, total_supply);
    }

    pub fn transfer_assets(&mut self, asset_name: String, from_account: String, to_account: String, amount: u64) -> bool {
        if self.is_asset_transferable(&asset_name) {
            if let Some(ledger) = self.ledgers.get_mut(&asset_name) {
                match ledger.transfer_asset(from_account.clone(), to_account.clone(), amount, &asset_name) {
                    Ok(log) => {
                        self.log_transaction(log);
                        return true;
                    }
                    Err(_) => return false,
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

    fn create_and_store_asset(&mut self, name: String, total_supply: u64) {
        let asset = Asset {
            name: name.clone(),
            total_supply,
            frozen: false,
        };
        self.assets.insert(name, asset);
    }

    fn is_asset_transferable(&self, asset_name: &String) -> bool {
        if let Some(asset) = self.assets.get(asset_name) {
            !asset.frozen
        } else {
            false
        }
    }

    fn log_transaction(&mut self, log: AssetTransferLog) {
        println!("{}", log);
        self.transaction_logs.push(log);
    }
}

fn main() {
    let mut asset_manager = AssetManager::new();

    asset_manager.issue_new_asset("Gold".to_string(), 1000, "Alice".to_string());
    if asset_manager.transfer_assets("Gold".to_string(), "Alice".to_string(), "Bob".to_string(), 100) {
        println!("Transaction completed successfully.");
    } else {
        println!("Transaction failed.");
    }

    let alice_balance = asset_manager.query_asset_balance(&"Gold".to_string(), &"Alice".to_string());
    let bob_balance = asset_manager.query_asset_balance(&"Gold".to_string(), &"Bob".to_string());

    println!("Alice's Gold balance: {}", alice_balance);
    println!("Bob's Gold balance: {}", bob_balance);
}