use log::info;
use prost::Message;
use std::sync::Arc;

use crate::core::Core;
use crate::core_proto::*;
use crate::requests::*;
use crate::rust_data::RustData;

pub fn dispatch_request(core: *mut Core, request: Request) -> RustData {
    assert!(!core.is_null());

    let core_ref = unsafe { core.as_ref().unwrap() };
    let core_arc = Arc::new(core_ref);

    info!(target: "rust", "Serving synchronous request on {:?}", std::thread::current());

    use crate::core_proto::request::SyncRequests::{SyncBacktrace, CreateAccount};

    let bytes = match request.sync_requests {
        Some(req) => {
            match req {
                SyncBacktrace(sync_backtrace_req) => handle_backtrace(sync_backtrace_req).encode_to_vec(),
                CreateAccount(create_account_req) => handle_create_account(create_account_req).encode_to_vec(),
            }
        },
        None => panic!("Invalid synchronous request"),
    };

    return RustData::from(bytes);
}
