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
        address: &str,
        payload: serde_json::Value,
    ) -> Result<String, AptosError> {
        let account: GetAccountResponse = match self.get_account(address).await {
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
            "sender": format!("0x{}", address),
            "sequence_number": sequence_number.to_string(),
            "max_gas_amount": "1000",
            "gas_unit_price": "1",
            "gas_currency_code": "XUS",
            "expiration_timestamp_secs": expiration_time_secs.to_string(),
            "payload": payload,
        }).to_string());
    }
    
    /// Converts a transaction produced by `generate_transaction` into a properly signed transaction,
    /// which can then be submitted to the blockchain.
    /// Specs here https://fullnode.devnet.aptoslabs.com/spec.html#/operations/create_signing_message
    pub async fn sign_transaction(
        &self,
        account_from: &mut AptosAccount,
        transaction: String,
    ) -> Result<String, AptosError> {
        let response = match self.http_client
            .post(format!("{}/transactions/signing_message", self.url))
            .body(transaction)
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

        let to_sign = hex::decode(&signing_message.message[2..]).unwrap();
        let signature: String = account_from.sign(&to_sign);

        return Ok(format!("0x{}", signature));
    }

    /// Submits a signed transaction to the blockchain.
    pub async fn submit_transaction(
        &self,
        transaction: String,
        signature_payload: serde_json::Value,
    ) -> Result<Transaction, AptosError> {
        let mut transaction_json: serde_json::Value = serde_json::from_str(&transaction).unwrap();

        transaction_json
            .as_object_mut()
            .unwrap()
            .insert("signature".to_string(), signature_payload);

        let response = match self.http_client
            .post(format!("{}/transactions", self.url))
            .body(transaction_json.to_string())
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest);
                }
            };

        return handle_response::<Transaction>(response).await;
    }

    /// Retrieve a transaction in the blockchain.
    pub async fn get_transaction(
        &self, 
        transaction_hash: &str
    ) -> Result<Transaction, AptosError> {
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

        return handle_response::<Transaction>(response).await;
    }

    /// Returns the sequence number and authentication key for an account
    /// Specs here https://fullnode.devnet.aptoslabs.com/spec.html#/operations/get_account_transactions
    pub async fn get_account_transactions(
        &self, 
        account_address: &str
    ) -> Result<Vec<Transaction>, AptosError> {
        let response = match self.http_client
            .get(format!("{}/accounts/{}/transactions", self.url, account_address))
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await {
                Ok(res) => res,
                Err(error) => {
                    log::error!("{}", error);
                    return Err(AptosError::InvalidRequest)
                },
            };

        let response_json = match handle_response::<serde_json::Value>(response).await {
            Ok(res) => res,
            Err(error) => return Err(error)
        };

        let transactions: Vec<Transaction> = match response_json.as_array() {
            Some(transactions) => transactions.iter().map(|t| Transaction{
                type_transaction: t["type"].as_str().unwrap().to_string(),
                hash: t["hash"].as_str().unwrap().to_string(),
                sequence_number: t["sequence_number"].as_str().unwrap().to_string(),
            }).collect(),
            None => return Err(AptosError::InvalidResponse),
        };

        return Ok(transactions);
    }
}
