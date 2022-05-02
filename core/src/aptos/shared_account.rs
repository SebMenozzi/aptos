use ed25519_dalek::{Keypair};
use rand::{SeedableRng, Rng, rngs::StdRng, rngs::OsRng};
use tiny_keccak::{Sha3, Hasher};

pub struct AptosSharedAccount {
    pub n: u8,
    pub k: u8,
    pub keypairs: Vec<Keypair>,
}

#[allow(dead_code)]
impl AptosSharedAccount {
    pub fn new(n: u8, k: u8) -> Self {
        let mut keypairs = Vec::new();

        for _ in 0..n {
            keypairs.push(Keypair::generate(&mut StdRng::from_seed(OsRng.gen())));
        }

        return Self { 
            n: n, 
            k: k, 
            keypairs: keypairs,
        }
    }

    /// Returns the address associated with the given account
    pub fn address(&self) -> String {
        let mut sha3 = Sha3::v256();

        for keypair in &self.keypairs {
            sha3.update(keypair.public.as_bytes());
        }

        sha3.update(&vec![self.k]);

        sha3.update(&vec![1u8]);

        let mut output = [0u8; 32];
        sha3.finalize(&mut output);

        return hex::encode(output);
    }
}