use crate::aptos::*;

pub struct AptosFaucetClient {
    url: String,
    http_client: reqwest::Client,
}

impl AptosFaucetClient {

    /// Faucet creates and funds accounts. This is a thin wrapper around that.
    pub fn new(url: String) -> Self {
        let http_client = reqwest::Client::new();

        return Self {
            url: url,
            http_client: http_client,
        };
    }

    /// This creates an account if it does not exist and mints the specified amount of coins into that account.
    pub async fn fund_account(
        &self, 
        auth_key: &str, 
        amount: u64
    ) -> Result<Vec<String>, AptosError> {
        let response = match self.http_client
            .post(format!("{}/mint?amount={}&auth_key={}", self.url, amount, auth_key))
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

        let transaction_hashes: Vec<String> = match response_json.as_array() {
            Some(hashes) => hashes.iter().map(|i| i.to_string()).collect(),
            None => return Err(AptosError::InvalidResponse),
        };

        return Ok(transaction_hashes);
    }
}