use crate::aptos::*;

pub struct Core {
    pub aptos_rest_client: AptosRestClient,
    pub aptos_faucet_client: AptosFaucetClient,
}

impl Core {
    pub fn new(
        aptos_rest_url: String,
        aptos_faucet_url: String,
    ) -> Core {
        let rest_client = AptosRestClient::new(aptos_rest_url);
        let faucet_client = AptosFaucetClient::new(aptos_faucet_url);

        return Self {
            aptos_rest_client: rest_client,
            aptos_faucet_client: faucet_client,
        }
    }
}