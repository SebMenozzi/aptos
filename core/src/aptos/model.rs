use serde::{Deserialize, Serialize};

// Get Account

#[derive(Debug, Serialize, Deserialize)]
pub struct GetAccountResponse {
    pub sequence_number: String,
    pub authentication_key: String,
}

// Create transaction signing

#[derive(Debug, Serialize, Deserialize)]
pub struct CreateTransactionSigningResponse {
    pub message: String,
}

// Transaction

#[derive(Debug, Serialize, Deserialize)]
pub struct TransactionResponse {
    #[serde(rename="type")]
    pub type_transaction: String,
    pub hash: String,
}

// Aptos Error

#[derive(Debug, Serialize, Deserialize)]
pub struct AptosErrorResponse {
    pub code: i64,
    pub message: String,
}