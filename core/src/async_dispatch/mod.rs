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

// Check that the callback has been deallocated
impl Drop for RustCallback {
    fn drop(&mut self) {
        log::debug!(target: "rust", "{:?} at {:?} dropped!", self, &self as *const _);
    }
}

unsafe impl Send for Core {}
unsafe impl Sync for Core {}

pub fn dispatch_request_async(core: *const Core, request: Request, callback: RustCallback) {
    assert!(!core.is_null());

    let core_arc = unsafe { Arc::from_raw(core) };

    RUNTIME.spawn(async move {        
        use crate::core_proto::request::AsyncRequests::{AsyncBacktrace, FundAccount, GetAccountBalance, Transfer};

        let bytes = match request.async_requests {
            Some(req) => {
                match req {
                    AsyncBacktrace(async_backtrace_req) => async { handle_backtrace(async_backtrace_req) }.await.encode_to_vec(),
                    FundAccount(fund_account_req) => handle_fund_account(core_arc, fund_account_req).await.encode_to_vec(),
                    GetAccountBalance(get_account_balance_req) => handle_get_account_balance(core_arc, get_account_balance_req).await.encode_to_vec(),
                    Transfer(transfer_req) => handle_transfer(core_arc, transfer_req).await.encode_to_vec(),
                }
            },
            None => return log::error!("Unhandled asynchronous request"),
        };

        callback.run(RustData::from(bytes));
    });
}
