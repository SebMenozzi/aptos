import UIKit

extension CALayer {

    /// Encapsulates the given Core Animation block in a transation with actions disabled.
    /// - Parameter actions: The actions to perform in a non-animated manner.
    ///
    /// Calling this method commits the transaction after running the provided actions.
    class func performWithoutAnimations(_ actions: () -> Void) {
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        actions()
        CATransaction.commit()
    }
}
