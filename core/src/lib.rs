mod async_dispatch;
mod sync_dispatch;
mod requests;
mod rust_data;
mod core;
mod aptos;

mod core_proto { include!(concat!(env!("OUT_DIR"), "/core_proto.rs")); }

/// Swift string to Rust String
fn raw_char_to_string(cchar: *const std::os::raw::c_char) -> String {
    let c_str = unsafe { std::ffi::CStr::from_ptr(cchar) };
    return c_str.to_str().unwrap().to_string();
}

/// Create a core object allocated to the heap, will return a raw pointer
#[no_mangle]
pub extern "C" fn create_core(
    aptos_rest_url: *const std::os::raw::c_char,
    aptos_faucet_url: *const std::os::raw::c_char,
) -> *mut core::Core {
    return Box::into_raw(Box::new(core::Core::new(
        raw_char_to_string(aptos_rest_url),
        raw_char_to_string(aptos_faucet_url),
    )));
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
