#[repr(C)]
#[derive(Debug)]
pub struct RustData {
    pub ptr: *const u8,
    pub len: usize,
    pub cap: usize,
    pub err: *const std::os::raw::c_char,
}

impl From<Vec<u8>> for RustData {
    fn from(bytes: Vec<u8>) -> Self {
        let ret = Self {
            ptr: bytes.as_ptr(),
            len: bytes.len(),
            cap: bytes.capacity(),
            err: std::ptr::null(),
        };

        std::mem::forget(bytes);

        return ret;
    }
}

impl RustData {
    fn from_err<E: ToString>(e: E) -> Self {
        let err_string = std::ffi::CString::new(e.to_string()).unwrap();

        return Self {
            ptr: std::ptr::null(),
            len: 0,
            cap: 0,
            err: err_string.into_raw(),
        };
    }
}

impl<E: ToString> From<Result<Vec<u8>, E>> for RustData {
    fn from(result: Result<Vec<u8>, E>) -> Self {
        match result {
            Ok(bytes) => Self::from(bytes),
            Err(error) => Self::from_err(error),
        }
    }
}

pub fn to_rust_data(data: *const u8, len: usize) -> crate::core_proto::Request {
    let bytes = unsafe { std::slice::from_raw_parts(data, len) };

    prost::Message::decode(bytes).expect("Invalid Message")
}
