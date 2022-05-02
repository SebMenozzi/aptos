use ed25519_dalek::{PublicKey, SecretKey};
use rand::SeedableRng;
use tiny_keccak::{Sha3, Hasher};
use rand::rngs::{StdRng, OsRng};
use rand::Rng;

pub struct AptosAccount {
    pub signing_key: SecretKey,
}

impl AptosAccount {
    /// Represents an account as well as the private, public key-pair for the Aptos blockchain.
    pub fn new(signing_key_bytes: Option<Vec<u8>>) -> Self {
        let signing_key = match signing_key_bytes {
            Some(key) => SecretKey::from_bytes(&key).unwrap(),
            None => SecretKey::generate(&mut StdRng::from_seed(OsRng.gen())),
        };

        return Self { signing_key };
    }

    /// Returns the address associated with the given account
    pub fn address(&self) -> String {
        let mut sha3 = Sha3::v256();
        sha3.update(PublicKey::from(&self.signing_key).as_bytes());
        sha3.update(&vec![0u8]);

        let mut output = [0u8; 32];
        sha3.finalize(&mut output);

        return hex::encode(output);
    }
    
    /// Returns the private key for the associated account
    pub fn public_key(&self) -> String {
        return hex::encode(PublicKey::from(&self.signing_key).as_bytes());
    }

    /// Returns the signing key in bytes
    pub fn signing_key_bytes(&self) -> Vec<u8> {
        return self.signing_key.as_bytes().to_vec();
    }
}
