use crate::aptos::*;

pub struct Core {
    pub aptos_client: AptosRestClient,
}

impl Core {
    pub fn new(aptos_url: &String) -> Core {
        Core {
            aptos_client: AptosRestClient::new((&aptos_url).to_string()),
        }
    }
}
