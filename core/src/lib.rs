mod async_dispatch;
mod sync_dispatch;
mod requests;
mod rust_data;
mod core;
mod aptos;
mod logger;

mod core_proto { include!(concat!(env!("OUT_DIR"), "/core_proto.rs")); }

use std::sync::Arc;
use log::{SetLoggerError, LevelFilter};
use crate::core::Core;
use crate::logger::Logger;

/// Swift string to str
fn raw_char_to_str(cchar: *const std::os::raw::c_char) -> &'static str {
    let c_str = unsafe { std::ffi::CStr::from_ptr(cchar) };
    return c_str.to_str().unwrap();
}

/// Swift string to Rust String
fn raw_char_to_string(cchar: *const std::os::raw::c_char) -> String {
    return raw_char_to_str(cchar).to_string();
}

fn init_logger(filter: LevelFilter) -> Result<(), SetLoggerError> {
    log::set_boxed_logger(Box::new(Logger))
        .map(|()| log::set_max_level(filter))
}

/// Create a core object allocated to the heap, will return a raw pointer
#[no_mangle]
pub extern "C" fn create_core(
    log_level: *const std::os::raw::c_char,
    aptos_rest_url: *const std::os::raw::c_char,
    aptos_faucet_url: *const std::os::raw::c_char,
) -> *const core::Core {
    let log_filter: LevelFilter = match raw_char_to_str(log_level) {
        "debug" => LevelFilter::Debug,
        "info" => LevelFilter::Info,
        "error" => LevelFilter::Error,
        "trace" => LevelFilter::Trace,
        "warn" => LevelFilter::Warn,
        _ => LevelFilter::Debug,
    };

    let _ = init_logger(log_filter).unwrap_or(());

    let core = Core::new(
        raw_char_to_string(aptos_rest_url),
        raw_char_to_string(aptos_faucet_url),
    );

    let core_arc = Arc::new(core);

    return Arc::into_raw(core_arc);
}

/// Deallocate core object
#[no_mangle]
pub unsafe extern "C" fn free_core(core: *mut core::Core) {
    assert!(!core.is_null());

    Box::from_raw(core);
}

/// Call a synchronous request
#[no_mangle]
pub extern "C" fn rust_call_sync(
    core: *mut core::Core,
    data: *const u8,
    len: usize,
) -> rust_data::RustData {
    let request = rust_data::to_rust_data(data, len);

    return sync_dispatch::dispatch_request(core, request);
}

/// Call an asynchronous request
#[no_mangle]
pub unsafe extern "C" fn rust_call_async(
    core: *mut core::Core,
    data: *const u8,
    len: usize,
    callback: async_dispatch::RustCallback,
) {
    let request = rust_data::to_rust_data(data, len);

    async_dispatch::dispatch_request_async(core, request, callback);
}

/// Free rust data
#[no_mangle]
pub unsafe extern "C" fn rust_free_data(data: rust_data::RustData) {
    let rust_data::RustData { ptr, len, cap, err } = data;

    let buf = Vec::from_raw_parts(ptr as *mut u8, len, cap);
    drop(buf);

    if !err.is_null() {
        let err_string = std::ffi::CString::from_raw(err as *mut _);
        drop(err_string)
    }
}
