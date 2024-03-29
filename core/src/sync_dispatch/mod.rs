use prost::Message;
use std::sync::Arc;

use crate::core::Core;
use crate::core_proto::*;
use crate::requests::*;
use crate::rust_data::RustData;

#[allow(unused_variables)] // TODO: remove this later
pub fn dispatch_request(core: *const Core, request: Request) -> RustData {
    assert!(!core.is_null());

    let core_arc = unsafe { Arc::from_raw(core) };

    use crate::core_proto::request::SyncRequests::{GetSyncBacktrace, CreateAccount, CreateWallet};

    let bytes = match request.sync_requests {
        Some(req) => {
            match req {
                GetSyncBacktrace(get_sync_backtrace_req) => handle_get_backtrace(get_sync_backtrace_req).encode_to_vec(),
                CreateAccount(create_account_req) => handle_create_account(create_account_req).encode_to_vec(),
                CreateWallet(create_wallet_req) => handle_create_wallet(create_wallet_req).encode_to_vec(),
            }
        },
        None => panic!("Unhandled synchronous request"),
    };

    return RustData::from(bytes);
}
