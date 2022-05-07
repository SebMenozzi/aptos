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
pub struct Transaction {
    #[serde(rename="type")]
    pub type_transaction: String,
    pub hash: String,
    pub sequence_number: String,
}

// Sign transaction

#[derive(Debug)]
pub struct SignedPayload {
    pub public_key: String,
    pub signature: String,
}