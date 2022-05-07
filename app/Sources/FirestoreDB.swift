import Foundation

public enum FirestoreDB {
    public enum Collections {
        public static let transactions = "transactions"
    }
    
    public enum Transaction {
        public static let amount = "amount"
        public static let rawTransaction = "raw_transaction"
        public static let signatures = "signatures"
        public static let transactionHash = "transaction_hash"
        public static let walletIdTo = "wallet_id_to"
        public static let walletIdFrom = "wallet_id_from"
    }
}
