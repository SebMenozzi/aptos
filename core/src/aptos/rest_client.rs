use ed25519_dalek::{PublicKey, ExpandedSecretKey};
use hex::ToHex;
use core::time::Duration;

use crate::aptos::*;

#[derive(Clone)]
pub struct AptosRestClient {
    url: String,
    http_client: reqwest::Client,
}

impl AptosRestClient {
    pub fn new(url: String) -> Self {
        let http_client = reqwest::Client::new();

        return Self {
            url: url,
            http_client: http_client,
        };
    }

    /// Returns the sequence number and authentication key for an account
    /// Specs here https://fullnode.devnet.aptoslabs.com/spec.html#/operations/get_account
    pub async fn get_account(
        &self, 
        account_address: &str
    ) -> Result<GetAccountResponse, AptosError> {
        let response = match self.http_client
            .get(format!("{}/accounts/{}", self.url, account_address))
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest)
                },
            };

        return handle_response::<GetAccountResponse>(response).await;
    }

    /// Returns all resources associated with the account
    /// Specs here https://fullnode.devnet.aptoslabs.com/spec.html#/operations/get_account_resources
    pub async fn get_account_resource(
        &self, 
        account_address: &str, 
        resource_type: &str
    ) -> Result<serde_json::Value, AptosError> {
        let response = match self.http_client
            .get(format!("{}/accounts/{}/resource/{}", self.url, account_address, resource_type))
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest)
                },
            };

        return handle_response::<serde_json::Value>(response).await;
    }

    /// Generate a transaction request that can be submitted to produce a raw transaction that can be signed
    /// which upon being signed can be submitted to the blockchain.
    /// Specs here https://fullnode.devnet.aptoslabs.com/spec.html#/schemas/Transaction
    pub async fn generate_transaction(
        &self,
        sender: &str,
        payload: serde_json::Value,
    ) -> Result<serde_json::Value, AptosError> {
        let account: GetAccountResponse = match self.get_account(sender).await {
            Ok(account) => account,
            Err(error) => return Err(error),
        };

        let sequence_number: u64 = match account.sequence_number.parse::<u64>() {
            Ok(number) => number,
            Err(error) => {
                log::error!("{}", error);
                return Err(AptosError::InvalidSequenceNumber)
            },
        };

        let expiration_time: Duration = match std::time::SystemTime::now().duration_since(std::time::UNIX_EPOCH) {
            Ok(time) => time,
            Err(error) => {
                log::error!("{}", error);
                return Err(AptosError::TimeWentBackwards)
            },
        };

        // Add 10 minutes (in seconds)
        let expiration_time_secs: u64 = expiration_time.as_secs() + 600;

        return Ok(serde_json::json!({
            "sender": format!("0x{}", sender),
            "sequence_number": sequence_number.to_string(),
            "max_gas_amount": "1000",
            "gas_unit_price": "1",
            "gas_currency_code": "XUS",
            "expiration_timestamp_secs": expiration_time_secs.to_string(),
            "payload": payload,
        }));
    }
    
    /// Converts a transaction produced by `generate_transaction` into a properly signed transaction,
    /// which can then be submitted to the blockchain.
    /// Specs here https://fullnode.devnet.aptoslabs.com/spec.html#/operations/create_signing_message
    pub async fn sign_transaction(
        &self,
        account_from: &mut AptosAccount,
        mut transaction: serde_json::Value,
    ) -> Result<serde_json::Value, AptosError> {
        let response = match self.http_client
            .post(format!("{}/transactions/signing_message", self.url))
            .body(transaction.to_string())
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest)
                },
            };

        let signing_message = match handle_response::<CreateTransactionSigningResponse>(response).await {
            Ok(message) => message,
            Err(error) => return Err(error),
        };

        // TODO: Convert unwrap to error to gracefully display the issue here
        let to_sign = hex::decode(&signing_message.message[2..]).unwrap();

        let signature: String = ExpandedSecretKey::from(&account_from.signing_key)
            .sign(&to_sign, &PublicKey::from(&account_from.signing_key))
            .encode_hex();

        let signature_payload: serde_json::Value = serde_json::json!({
            "type": "ed25519_signature",
            "public_key": format!("0x{}", account_from.public_key()),
            "signature": format!("0x{}", signature),
        });

        transaction
            .as_object_mut()
            .unwrap()
            .insert("signature".to_string(), signature_payload);

        return Ok(transaction);
    }

    /// Submits a signed transaction to the blockchain.
    pub async fn submit_transaction(
        &self, 
        transaction: &serde_json::Value
    ) -> Result<TransactionResponse, AptosError> {
        let response = match self.http_client
            .post(format!("{}/transactions", self.url))
            .body(transaction.to_string())
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest);
                }
            };

        return handle_response::<TransactionResponse>(response).await;
    }

    /// Retrieve a transaction in the blockchain.
    pub async fn get_transaction(
        &self, 
        transaction_hash: &str
    ) -> Result<TransactionResponse, AptosError> {
        let response = match self.http_client
            .get(format!("{}/transactions/{}", self.url, transaction_hash))
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest)
                },
            };

        return handle_response::<TransactionResponse>(response).await;
    }
}
