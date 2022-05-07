use std::sync::Arc;

use crate::core::Core;
use crate::core_proto::*;
use crate::aptos::*;

const BITMAP_NUM_OF_BYTES: usize = 4;

pub fn handle_get_backtrace(_req: GetBacktraceRequest) -> Box<GetBacktraceResponse> {
    let bt = backtrace::Backtrace::new();

    let response = GetBacktraceResponse {
        text: format!("{:?}", bt),
        ..Default::default()
    };

    return Box::new(response);
}

pub fn handle_create_account(_req: CreateAccountRequest) -> Box<CreateAccountResponse> {
    let account = AptosAccount::new(None);

    let response = CreateAccountResponse {
        keypair: account.keypair(),
        public_key: account.public_key(),
        ..Default::default()
    };

    return Box::new(response);
}

pub fn handle_create_wallet(req: CreateWalletRequest) -> Box<CreateWalletResponse> {
    let mut wallet = AptosSharedWallet::new();

    for public_key in req.public_keys {
        wallet.add_public_key(public_key);
    }

    let response = CreateWalletResponse {
        address: wallet.address(),
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_fund_wallet(core: Arc<Core>, req: FundWalletRequest) -> Box<FundWalletResponse> {
    let transactions = core.aptos_faucet_client.fund_account(&req.address, req.amount)
        .await
        .unwrap();

    let response = FundWalletResponse {
        transactions: transactions.iter().map(|hash| Transaction {
            type_transaction: String::from("pending_transaction"),
            hash: hash.to_string(),
        }).collect(),
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_get_wallet_balance(core: Arc<Core>, req: GetWalletBalanceRequest) -> Box<GetWalletBalanceResponse> {
    let balance = core.aptos_rest_client.get_account_resource(&req.address, "0x1::TestCoin::Balance")
        .await
        .unwrap()["data"]["coin"]["value"]
        .as_str()
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap();

    let response = GetWalletBalanceResponse {
        balance: balance,
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_create_wallet_transaction(core: Arc<Core>, req: CreateWalletTransactionRequest) -> Box<CreateWalletTransactionResponse> {
    let payload = serde_json::json!({
        "type": "script_function_payload",
        "function": "0x1::TestCoin::transfer",
        "type_arguments": [],
        "arguments": [format!("0x{}", req.address_to), req.amount.to_string()],
    });

    let transaction = core.aptos_rest_client.generate_transaction(&req.address_from, payload)
        .await
        .unwrap();

    let response = CreateWalletTransactionResponse {
        transaction: transaction,
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_sign_wallet_transaction(core: Arc<Core>, req: SignWalletTransactionRequest) -> Box<SignWalletTransactionResponse> {
    let mut account_from = AptosAccount::new(Some(req.keypair));
    
    let signature = core.aptos_rest_client.sign_transaction(&mut account_from, req.transaction)
        .await
        .unwrap();

    let response = SignWalletTransactionResponse {
        signature: signature,
        ..Default::default()
    };

    return Box::new(response);
}

fn bitmap_set_bit(input: &mut [u8; BITMAP_NUM_OF_BYTES], index: usize) {
    let bucket = index / 8;
    // It's always invoked with index < 32, thus there is no need to check range.
    let bucket_pos = index - (bucket * 8);
    input[bucket] |= 128 >> bucket_pos as u8;
}

pub async fn handle_submit_wallet_transaction(core: Arc<Core>, req: SubmitWalletTransactionRequest) -> Box<SubmitWalletTransactionResponse> {
    let public_keys: Vec<String> = req.signed_payloads.iter().map(|s| s.public_key.clone()).collect();
    let signatures: Vec<String> = req.signed_payloads.iter().map(|s| s.signature.clone()).collect();

    let mut bitmap = [0u8; BITMAP_NUM_OF_BYTES];

    for i in 0..signatures.len() {
        bitmap_set_bit(&mut bitmap, i);
    }

    let signature_payload: serde_json::Value = serde_json::json!({
        "type": "multi_ed25519_signature",
        "public_keys": serde_json::json!(public_keys),
        "signatures": serde_json::json!(signatures),
        "threshold": signatures.len(),
        "bitmap": format!("0x{}", hex::encode(bitmap)),
    });

    let transaction = core.aptos_rest_client.submit_transaction(req.transaction, signature_payload)
        .await
        .unwrap();

    let response = SubmitWalletTransactionResponse {
        transaction: Some(Transaction {
            type_transaction: transaction.type_transaction.clone(),
            hash: transaction.hash.clone(),
        }),
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_get_wallet_transactions(core: Arc<Core>, req: GetWalletTransactionsRequest)  -> Box<GetWalletTransactionsResponse> {
    let transactions = core.aptos_rest_client.get_account_transactions(&req.address)
        .await
        .unwrap();

    let response = GetWalletTransactionsResponse {
        transactions: transactions.iter().map(|t| Transaction {
            type_transaction: t.type_transaction.clone(),
            hash: t.hash.clone(),
        }).collect(),
        ..Default::default()
    };

    return Box::new(response);
}