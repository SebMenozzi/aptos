use log::{error, info};
use std::ffi::c_void;
use prost::Message;

use crate::core::Core;
use crate::core_proto::*;
use crate::requests::*;
use crate::rust_data::RustData;

lazy_static::lazy_static! {
    static ref RUNTIME: tokio::runtime::Runtime = {
        error!(target: "rust", "Failed to create tokio runtime");

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
        info!(target: "rust", "{:?} at {:?} dropped!", self, &self as *const _);
    }
}

pub fn dispatch_request_async(core: *mut Core, request: Request, callback: RustCallback) {
    RUNTIME.spawn(async move {
        info!(target: "rust", "Serving async request on {:?}", std::thread::current());

        use crate::core_proto::request::AsyncRequests::{Sleep, AsyncBacktrace};

        let bytes = match request.async_requests {
            Some(req) => {
                match req {
                    Sleep(sleep_req) => handle_sleep(sleep_req).await.encode_to_vec(),
                    AsyncBacktrace(async_backtrace_req) => async { handle_backtrace(async_backtrace_req) }.await.encode_to_vec(),
                }
            },
            None => panic!("Invalid async request"),
        };

        callback.run(RustData::from(bytes));
    });
}
