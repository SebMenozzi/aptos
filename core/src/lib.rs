mod async_dispatch;
mod sync_dispatch;
mod requests;
mod rust_data;
mod core;
mod aptos;

mod core_proto { include!(concat!(env!("OUT_DIR"), "/core_proto.rs")); }

#[no_mangle]
pub extern "C" fn create_core(aptos_url: *const std::os::raw::c_char) -> *mut core::Core {
    let c_str = unsafe { std::ffi::CStr::from_ptr(aptos_url) };
    let rust_str = c_str.to_str().unwrap().to_string();

    return Box::into_raw(Box::new(core::Core::new(&rust_str)));
}

#[no_mangle]
pub unsafe extern "C" fn free_core(core: *mut core::Core) {
    assert!(!core.is_null());

    Box::from_raw(core);
}

#[no_mangle]
pub extern "C" fn rust_call(
    core: *mut core::Core,
    data: *const u8,
    len: usize,
) -> rust_data::RustData {
    let request = rust_data::to_rust_data(data, len);

    return sync_dispatch::dispatch_request(core, request);
}

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
