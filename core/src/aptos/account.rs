use ed25519_dalek::{Keypair};
use rand::{SeedableRng, Rng, rngs::StdRng, rngs::OsRng};
use hex::ToHex;
use ed25519_dalek::Signer;

pub struct AptosAccount {
    pub keypair: Keypair,
}

impl AptosAccount {
    pub fn new(keypair_opt: Option<String>) -> Self {
        let keypair = match keypair_opt {
            Some(key) => {
                let keypair_bytes = hex::decode(key).unwrap();

                Keypair::from_bytes(&keypair_bytes).unwrap()
            },
            None => Keypair::generate(&mut StdRng::from_seed(OsRng.gen())),
        };

        return Self { keypair };
    }
    
    /// Returns the public key hex encoded
    pub fn public_key(&self) -> String {
        return hex::encode(self.keypair.public.as_bytes());
    }

    /// Returns the keypair in bytes
    pub fn keypair(&self) -> String {
        return hex::encode(self.keypair.to_bytes());
    }

    pub fn sign(&self, to_sign: &[u8]) -> String {
        return self.keypair.sign(to_sign).encode_hex();
    }
}
