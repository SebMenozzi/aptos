import Foundation

enum FirestoreDB {
    
    enum Collections {
        public static let account = "account"
        public static let wallet = "wallet"
        public static let transaction = "transaction"
    }
    
    enum Account {
        public static let username = "username"
        public static let public_key = "public_key"
    }
    
    enum Wallet {
        public static let address = "address"
        public static let public_keys = "public_keys"
    }
    
    enum Transaction {
        public static let hash = "hash"
        public static let amount = "amount"
        public static let rawTransaction = "raw_transaction"
        public static let signatures = "signatures"
        public static let walletIdTo = "wallet_id_to"
        public static let walletIdFrom = "wallet_id_from"
    }
}
