#[derive(Debug)]
pub enum AptosError {
    GetAccountRequest,
    GetAccountResponse,

    GetAccountResourceRequest,
    GetAccountResourceResponse,

    CreateTransactionSigningRequest,
    CreateTransactionSigningResponse,

    SubmitTransactionRequest,
    SubmitTransactionResponse,

    MintAccountRequest,
    MintAccountResponse,

    GetTransactionRequest,
    GetTransactionResponse,

    InvalidSequenceNumber,
    TimeWentBackwards,
}