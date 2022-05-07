//
//  Aptos.swift
//  App
//
//  Created by Anthony Humay on 5/7/22.
//

import Foundation

func createAccount(_ core: OpaquePointer) -> CoreProto_CreateAccountResponse {
    let request = CoreProto_Request.with {
        $0.createAccount = CoreProto_CreateAccountRequest()
    }
    
    let response: CoreProto_CreateAccountResponse = try! rustCallSync(core, request)
    
    return response
}

func createWallet(_ core: OpaquePointer, publicKeys: [String]) -> CoreProto_CreateWalletResponse {
    let createWalletRequest = CoreProto_CreateWalletRequest()..{
        $0.publicKeys = publicKeys
    }
    
    let request = CoreProto_Request.with {
        $0.createWallet = createWalletRequest
    }
    
    let response: CoreProto_CreateWalletResponse = try! rustCallSync(core, request)
    
    return response
}

func fundWallet(
    _ core: OpaquePointer,
    address: String,
    amount: UInt64
) async throws -> CoreProto_Transaction? {
    let fundWalletRequest = CoreProto_FundWalletRequest.with {
        $0.address = address
        $0.amount = amount
    }
    
    let req = CoreProto_Request.with {
        $0.fundWallet = fundWalletRequest
    }
    
    let res: CoreProto_FundWalletResponse? = try? await rustCallAsyncAwait(core, req)
    
    return res?.transactions.first
}

func getWalletBalance(
    _ core: OpaquePointer,
    address: String
) async throws -> UInt64? {
    let getWalletBalanceRequest = CoreProto_GetWalletBalanceRequest.with {
        $0.address = address
    }
    
    let req = CoreProto_Request.with {
        $0.getWalletBalance = getWalletBalanceRequest
    }
    
    let res: CoreProto_GetWalletBalanceResponse? = try? await rustCallAsyncAwait(core, req)
    
    return res?.balance
}

func getWalletTransactions(
    _ core: OpaquePointer,
    address: String
) async throws -> [CoreProto_Transaction]? {
    let getWalletTransactionsRequest = CoreProto_GetWalletTransactionsRequest.with {
        $0.address = address
    }
    
    let req = CoreProto_Request.with {
        $0.getWalletTransactions = getWalletTransactionsRequest
    }
    
    let res: CoreProto_GetWalletTransactionsResponse? = try? await rustCallAsyncAwait(core, req)
    
    return res?.transactions
}

func createWalletTransaction(
    _ core: OpaquePointer,
    amount: UInt64,
    addressFrom: String,
    addressTo: String
) async throws -> String?  {
    let createWalletTransactionRequest = CoreProto_CreateWalletTransactionRequest.with {
        $0.amount = amount
        $0.addressFrom = addressFrom
        $0.addressTo = addressTo
    }
    
    let req = CoreProto_Request.with {
        $0.createWalletTransaction = createWalletTransactionRequest
    }
    
    let res: CoreProto_CreateWalletTransactionResponse? = try? await rustCallAsyncAwait(core, req)
    
    return res?.transaction
}

func signWalletTransaction(
    _ core: OpaquePointer,
    transaction: String,
    keypair: Data
) async throws -> String?  {
    let signWalletTransactionRequest = CoreProto_SignWalletTransactionRequest.with {
        $0.transaction = transaction
        $0.keypair = keypair
    }
    
    let req = CoreProto_Request.with {
        $0.signWalletTransaction = signWalletTransactionRequest
    }
    
    let res: CoreProto_SignWalletTransactionResponse? = try? await rustCallAsyncAwait(core, req)
    
    return res?.signature
}

func submitWalletTransaction(
    _ core: OpaquePointer,
    transaction: String,
    signedPayloads: [CoreProto_SignedPayload]
) async throws -> CoreProto_Transaction?  {
    let submitWalletTransactionRequest = CoreProto_SubmitWalletTransactionRequest.with {
        $0.transaction = transaction
        $0.signedPayloads = signedPayloads
    }
    
    let req = CoreProto_Request.with {
        $0.submitWalletTransaction = submitWalletTransactionRequest
    }
    
    let res: CoreProto_SubmitWalletTransactionResponse? = try? await rustCallAsyncAwait(core, req)
    
    return res?.transaction
}


func backtrace(_ core: OpaquePointer, sync: Bool, closure: @escaping (String) -> Void) {
    let req = CoreProto_Request.with {
        if sync {
            $0.getSyncBacktrace = CoreProto_GetBacktraceRequest()
        } else {
            $0.getAsyncBacktrace = CoreProto_GetBacktraceRequest()
        }
    }
    
    if sync {
        let res: CoreProto_GetBacktraceResponse = try! rustCallSync(core, req)
        closure(res.text)
    } else {
        rustCallAsyncClosure(core, req) { (res: CoreProto_GetBacktraceResponse) in closure(res.text) }
    }
}
