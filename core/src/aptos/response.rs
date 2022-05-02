#[derive(Debug)]
pub enum AptosError {
    InvalidJSON,
    InvalidRequest,
    InvalidResponse,

    InvalidSequenceNumber,
    TimeWentBackwards,
}

pub async fn handle_response<T: serde::de::DeserializeOwned>(
    response: reqwest::Response,
) -> Result<T, AptosError> {
    let json: serde_json::Value = match response.json().await {
        Ok(res) => res,
        Err(error) => {
            log::error!("{}", error);
            return Err(AptosError::InvalidJSON)
        },
    };

    let aptos_error_message: String = json["message"].as_str().unwrap_or("").to_string();

    let obj = match serde_json::from_value::<T>(json) {
        Ok(res) => res,
        Err(error) => {
            if aptos_error_message.len() != 0 {
                log::error!("{}", aptos_error_message);
            } else {
                log::error!("{}", error);
            }

            return Err(AptosError::InvalidResponse)
        },
    };

    return Ok(obj);
}