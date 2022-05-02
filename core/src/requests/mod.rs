use std::sync::Arc;

use crate::core::Core;
use crate::core_proto::*;
use crate::aptos::*;

pub fn handle_create_account(_req: CreateAccountRequest) -> Box<CreateAccountResponse> {
    let account = AptosAccount::new(None);

    let response = CreateAccountResponse {
        address: account.address(),
        signing_key: account.signing_key_bytes(),
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_fund_account(core: Arc<Core>, req: FundAccountRequest) -> Box<FundAccountResponse> {
    let transactions = core.aptos_faucet_client.fund_account(&req.address, req.amount)
        .await
        .unwrap();

    let response = FundAccountResponse {
        transactions: transactions.iter().map(|hash| Transaction {
            type_transaction: String::from("pending_transaction"),
            hash: hash.to_string(),
        }).collect(),
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_get_account_balance(core: Arc<Core>, req: GetAccountBalanceRequest) -> Box<GetAccountBalanceResponse> {
    let balance = core.aptos_rest_client.get_account_resource(&req.address, "0x1::TestCoin::Balance")
        .await
        .unwrap()["data"]["coin"]["value"]
        .as_str()
        .and_then(|s| s.parse::<u64>().ok())
        .unwrap();

    let response = GetAccountBalanceResponse {
        balance: balance,
        ..Default::default()
    };

    return Box::new(response);
}

pub async fn handle_transfer(core: Arc<Core>, req: TransferRequest) -> Box<TransferResponse> {
    let payload = serde_json::json!({
        "type": "script_function_payload",
        "function": "0x1::TestCoin::transfer",
        "type_arguments": [],
        "arguments": [format!("0x{}", req.address_to), req.amount.to_string()],
    });

    let transaction = core.aptos_rest_client.generate_transaction(&req.address_from, payload)
        .await
        .unwrap();

    let mut account_from = AptosAccount::new(Some(req.signing_key));
    
    let signed_transaction = core.aptos_rest_client.sign_transaction(&mut account_from, transaction)
        .await
        .unwrap();

    let final_transaction = core.aptos_rest_client.submit_transaction(&signed_transaction)
        .await
        .unwrap();

    let response = TransferResponse {
        transaction: Some(Transaction {
            type_transaction: final_transaction.type_transaction,
            hash: final_transaction.hash,
        }),
        ..Default::default()
    };

    return Box::new(response);
}

pub fn handle_backtrace(_req: BacktraceRequest) -> Box<BacktraceResponse> {
    let bt = backtrace::Backtrace::new();

    let response = BacktraceResponse {
        text: format!("{:?}", bt),
        ..Default::default()
    };

    return Box::new(response);
}