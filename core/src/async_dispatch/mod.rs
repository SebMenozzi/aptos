use std::ffi::c_void;
use prost::Message;
use std::sync::Arc;

use crate::core::Core;
use crate::core_proto::*;
use crate::requests::*;
use crate::rust_data::RustData;

lazy_static::lazy_static! {
    static ref RUNTIME: tokio::runtime::Runtime = {
        tokio::runtime::Runtime::new().expect("Failed to create tokio runtime")
    };
}

#[repr(C)]
#[derive(Debug)]
pub struct RustCallback {
    pub swift_callback_ptr: *const c_void,
    pub callback: extern "C" fn(*const c_void, RustData),
}
unsafe impl Send for RustCallback {}

impl RustCallback {
    pub fn new(swift_callback_ptr: *const c_void, callback_ptr: *const c_void) -> Self {
        Self {
            swift_callback_ptr: swift_callback_ptr,
            // Converts a pointer to a fn pointer
            callback: unsafe { std::mem::transmute(callback_ptr) },
        }
    }

    pub fn run(self, response_data: RustData) {
        (self.callback)(self.swift_callback_ptr, response_data);
    }
}

unsafe impl Send for Core {}
unsafe impl Sync for Core {}

pub fn dispatch_request_async(core: *const Core, request: Request, callback: RustCallback) {
    assert!(!core.is_null());

    let core_arc = unsafe { Arc::from_raw(core) };

    RUNTIME.spawn(async move {        
        use crate::core_proto::request::AsyncRequests::{GetAsyncBacktrace, FundWallet, GetWalletBalance, CreateWalletTransaction, SignWalletTransaction, SubmitWalletTransaction, GetWalletTransactions};

        let bytes = match request.async_requests {
            Some(req) => {
                match req {
                    GetAsyncBacktrace(get_async_backtrace_req) => async { handle_get_backtrace(get_async_backtrace_req) }.await.encode_to_vec(),
                    FundWallet(fund_req) => handle_fund_wallet(core_arc, fund_req).await.encode_to_vec(),
                    GetWalletBalance(get_balance_req) => handle_get_wallet_balance(core_arc, get_balance_req).await.encode_to_vec(),
                    CreateWalletTransaction(create_transaction_req) => handle_create_wallet_transaction(core_arc, create_transaction_req).await.encode_to_vec(),
                    SignWalletTransaction(sign_transaction_req) => handle_sign_wallet_transaction(core_arc, sign_transaction_req).await.encode_to_vec(),
                    SubmitWalletTransaction(submit_transaction_req) => handle_submit_wallet_transaction(core_arc, submit_transaction_req).await.encode_to_vec(),
                    GetWalletTransactions(get_wallet_transactions_req) => handle_get_wallet_transactions(core_arc, get_wallet_transactions_req).await.encode_to_vec(),
                }
            },
            None => return log::error!("Unhandled asynchronous request"),
        };

        callback.run(RustData::from(bytes));
    });
}
