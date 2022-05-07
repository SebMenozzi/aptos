use ed25519_dalek::{Keypair};
use rand::{SeedableRng, Rng, rngs::StdRng, rngs::OsRng};
use hex::ToHex;
use ed25519_dalek::Signer;

pub struct AptosAccount {
    pub keypair: Keypair,
}

impl AptosAccount {
    pub fn new(keypair_bytes: Option<Vec<u8>>) -> Self {
        let keypair = match keypair_bytes {
            Some(key) => Keypair::from_bytes(&key).unwrap(),
            None => Keypair::generate(&mut StdRng::from_seed(OsRng.gen())),
        };

        return Self { keypair };
    }
    
    /// Returns the public key hex encoded
    pub fn public_key(&self) -> String {
        return hex::encode(self.keypair.public.as_bytes());
    }

    /// Returns the keypair in bytes
    pub fn keypair_bytes(&self) -> Vec<u8> {
        return self.keypair.to_bytes().to_vec();
    }

    pub fn sign(&self, to_sign: &[u8]) -> String {
        return self.keypair.sign(to_sign).encode_hex();
    }
}
