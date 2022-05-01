use serde::{Deserialize, Serialize};

#[derive(Clone)]
pub struct AptosRestClient {
    url: String,
    client: reqwest::Client,
}

#[derive(Debug, Serialize, Deserialize)]
struct GetAccountResponse {
    sequence_number: String,
    authentication_key: String,
}

#[derive(Debug, Serialize, Deserialize)]
struct GetAccountResourcesResponse {
    sequence_number: String,
    authentication_key: String,
}

impl AptosRestClient {
    pub fn new(url: String) -> Self {
        let client = reqwest::Client::new();

        return Self {
            url: url,
            client: client,
        };
    }

    // Returns the sequence number and authentication key for an account
    pub async fn account(&self, account_address: &str) -> Result<GetAccountResponse, reqwest::Error> {
        let response = self
            .client
            .get(format!("{}/accounts/{}", self.url, account_address))
            .header(reqwest::header::CONTENT_TYPE, "application/json")
            .send()
            .await
            .unwrap();

        return response.json::<GetAccountResponse>().await
    }

    // Create a transaction request that can be submitted to produce a raw transaction that can be signed
    // which upon being signed can be submitted to the blockchain.
    pub async fn create_transaction(
        &self,
        sender: &str,
        payload: serde_json::Value,
    ) -> serde_json::Value {
        let sequence_number = self
            .account(sender)
            .await
            .unwrap()
            .sequence_number
            .parse::<u64>()
            .unwrap();

        // Unix timestamp, in seconds + 10 minutes
        let expiration_time_secs = std::time::SystemTime::now()
            .duration_since(std::time::UNIX_EPOCH)
            .expect("Time went backwards")
            .as_secs()
            + 600;

        return serde_json::json!({
            "sender": format!("0x{}", sender),
            "sequence_number": sequence_number.to_string(),
            "max_gas_amount": "1000",
            "gas_unit_price": "1",
            "gas_currency_code": "XUS",
            "expiration_timestamp_secs": expiration_time_secs.to_string(),
            "payload": payload,
        });
    }
}
