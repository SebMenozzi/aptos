import UIKit

extension UIScrollView {
    static func makeVertical(with verticalControllers: [UIViewController], in parent: UIViewController) -> UIScrollView {
        let scrollView = UIScrollView()..{
            $0.backgroundColor = .clear
            $0.isPagingEnabled = true
            $0.bounces = false
            $0.showsHorizontalScrollIndicator = false
            $0.showsVerticalScrollIndicator = false
            $0.isDirectionalLockEnabled = true
            $0.contentInsetAdjustmentBehavior = .never
        }

        func add(_ child: UIViewController, withOffset offset: CGFloat) {
            parent.addChild(child)
            scrollView.addSubview(child.view)
            child.didMove(toParent: parent)
            child.view.translatesAutoresizingMaskIntoConstraints = false

            child.view.widthAnchor.constraint(equalTo: scrollView.widthAnchor).isActive = true
            child.view.heightAnchor.constraint(equalTo: scrollView.heightAnchor).isActive = true
            child.view.transform = .init(translationX: 0, y: offset)
        }

        let width = UIScreen.main.bounds.width
        let height = UIScreen.main.bounds.height

        for (index, controller) in verticalControllers.enumerated() {
            let yPosition = CGFloat(index) * height

            add(controller, withOffset: yPosition)
        }

        scrollView.contentSize = CGSize(width: width, height: height * CGFloat(verticalControllers.count))
        scrollView.setContentOffset(CGPoint(x: 0, y: height), animated: false)

        return scrollView
    }
}
