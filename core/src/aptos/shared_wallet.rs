use ed25519_dalek::{PublicKey};
use tiny_keccak::{Sha3, Hasher};

pub struct AptosSharedWallet {
    pub public_keys: Vec<PublicKey>,
}

#[allow(dead_code)]
impl AptosSharedWallet {
    pub fn new() -> Self {
        return Self {
            public_keys: Vec::new(),
        }
    }

    pub fn add_public_key(&mut self, public_key: String) {
        let public_key_bytes = hex::decode(public_key).unwrap();

        self.public_keys.push(
            PublicKey::from_bytes(&public_key_bytes).unwrap()
        );
    }

    /// Returns the address associated with the given wallet
    pub fn address(&self) -> String {
        let mut sha3 = Sha3::v256();

        for public_key in &self.public_keys {
            sha3.update(public_key.as_bytes());
        }

        let k: usize = self.public_keys.len();

        sha3.update(&vec![k as u8]);

        sha3.update(&vec![1u8]);

        let mut output = [0u8; 32];
        sha3.finalize(&mut output);

        return hex::encode(output);
    }
}