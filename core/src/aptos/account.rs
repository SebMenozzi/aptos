use ed25519_dalek::{Keypair};
use rand::{SeedableRng, Rng, rngs::StdRng, rngs::OsRng};
use tiny_keccak::{Sha3, Hasher};
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

    /// Returns the address associated with the given account
    pub fn address(&self) -> String {
        let mut sha3 = Sha3::v256();
        sha3.update(self.keypair.public.as_bytes());
        sha3.update(&vec![0u8]);

        let mut output = [0u8; 32];
        sha3.finalize(&mut output);

        return hex::encode(output);
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
