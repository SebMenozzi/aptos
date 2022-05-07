import FirebaseFirestore

// Dependency Injection based on the "How to Control the World" article:
// https://www.pointfree.co/blog/posts/21-how-to-control-the-world
final class CurrentService {
    
    private let core_: OpaquePointer?
    private let firestore_: Firestore?

    init(core: OpaquePointer? = nil, firestore: Firestore? = nil) {
        self.core_ = core
        self.firestore_ = firestore
    }
    
    func core() -> OpaquePointer { return core_! }
    func firestore() -> Firestore { return firestore_! }
}

var Current = CurrentService()
