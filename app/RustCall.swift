import Foundation
import SwiftProtobuf

struct RustError: Error {
    public let error: String
}

private func rustDataToData(_ rustData: RustData) -> (Data?, RustError?) {
    var error: RustError? = nil
    var data: Data? = nil

    if let err = rustData.err {
        error = RustError(error: String(cString: err)) // Copy
    } else {
        data = Data(UnsafeRawBufferPointer(start: rustData.ptr, count: Int(rustData.len))) // Copy
    }

    return (data, error)
}

// MARK: - Sync

func rustCall<Response: SwiftProtobuf.Message>(_ core: OpaquePointer, _ request: CoreProto_Request) throws -> Response {
    // Request Proto Message to Request Swift Data
    let requestData = try! request.serializedData()

    let response = requestData.withUnsafeBytes { ptr -> RustData in
        let ptr = ptr.bindMemory(to: UInt8.self).baseAddress
        return rust_call_sync(core, ptr, UInt(requestData.count))
    }

    let (responseData, error) = rustDataToData(response)

    defer { rust_free_data(response) }

    if let responseData = responseData {
        let res = try Response(serializedData: responseData)
        return res
    } else {
        throw error!
    }
}


// MARK: - Async

private class SwiftCallback {

    private let callback: (Data) -> Void
    private let errorCallback: (RustError) -> Void
    private let onMainThread: Bool

    init(
        callback: @escaping (Data) -> Void,
        errorCallback: @escaping (RustError) -> Void,
        onMainThread: Bool
    ) {
        self.callback = callback
        self.errorCallback = errorCallback
        self.onMainThread = onMainThread
    }

    func run(_ data: Data?, _ error: RustError?) {
        let block = {
            if let error = error {
                self.errorCallback(error)
            } else {
                self.callback(data!)
            }
        }
        
        if onMainThread {
            DispatchQueue.main.async(execute: block)
        } else {
            block()
        }
    }
}

func rustCallAsyncClosure<Response: SwiftProtobuf.Message>(
    _ core: OpaquePointer,
    _ request: CoreProto_Request,
    onMainThread: Bool = true,
    closure: @escaping (Response) -> Void
) {
    let swiftCallback = SwiftCallback(
        callback: { (responseData: Data) in
            let res = try! Response(serializedData: responseData)
            closure(res)
        },
        errorCallback: { e in print("rustCallAsync error: \(e)") },
        onMainThread: onMainThread
    )
    let swiftCallbackPtr = Unmanaged.passRetained(swiftCallback).toOpaque()
    
    // We need to pass swiftCallbackPtr in the callback because
    // we can't pass it in the closure
    let rustCallback = RustCallback(
        swift_callback_ptr: swiftCallbackPtr,
        callback: { (swiftCallbackPtr: UnsafeRawPointer?, response: RustData) in
            let (data, resError) = rustDataToData(response)

            defer { rust_free_data(response) }

            let swiftCallback: SwiftCallback = Unmanaged.fromOpaque(swiftCallbackPtr!).takeRetainedValue()

            swiftCallback.run(data, resError)
        }
    )

    // Request Proto Message to Request Swift Data
    let requestData = try! request.serializedData()

    requestData.withUnsafeBytes { ptr -> Void in
        let ptr = ptr.bindMemory(to: UInt8.self).baseAddress

        rust_call_async(core, ptr, UInt(requestData.count), rustCallback)
    }
}

func rustCallAsyncAwait<Response: SwiftProtobuf.Message>(
    _ core: OpaquePointer,
    _ request: CoreProto_Request,
    onMainThread: Bool = true
) async throws -> Response {
    return try await withCheckedThrowingContinuation({
        (continuation: CheckedContinuation<Response, Error>) in
        
        rustCallAsyncClosure(core, request, onMainThread: onMainThread) { message in
            continuation.resume(returning: message)
        }
    })
}
