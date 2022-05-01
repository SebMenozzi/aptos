use log::info;
use prost::Message;

use crate::core::Core;
use crate::core_proto::*;
use crate::requests::*;
use crate::rust_data::RustData;

pub fn dispatch_request(core: *mut Core, request: Request) -> RustData {
    info!(target: "rust", "Serving sync request on {:?}", std::thread::current());

    use crate::core_proto::request::SyncRequests::{Greeting, SyncBacktrace};

    let bytes = match request.sync_requests {
        Some(req) => {
            match req {
                Greeting(greeting_req) => handle_greeting(greeting_req).encode_to_vec(),
                SyncBacktrace(sync_backtrace_req) => handle_backtrace(sync_backtrace_req).encode_to_vec(),
            }
        },
        None => panic!("Invalid sync request"),
    };

    return RustData::from(bytes);
}
