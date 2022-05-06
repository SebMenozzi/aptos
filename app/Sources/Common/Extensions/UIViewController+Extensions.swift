import UIKit

extension UIViewController {
    // MARK: Modal

    func pushViewControllerModal(vc: UIViewController) {
        let transition = CATransition()..{
            $0.duration = 0.2
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            $0.type = .moveIn
            $0.subtype = .fromTop
        }

        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }

    func dismissViewControllerModal() {
        let transition = CATransition()..{
            $0.duration = 0.2
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            $0.type = .reveal
            $0.subtype = .fromBottom
        }

        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.popViewController(animated: false)
    }

    func pushViewControllerFade(vc: UIViewController) {
        let transition = CATransition()..{
            $0.duration = 0.2
            $0.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            $0.type = .fade
        }

        navigationController?.view.layer.add(transition, forKey: nil)
        navigationController?.pushViewController(vc, animated: false)
    }

    func showActivityIndicatory() {
        let container = UIView()..{
            $0.id = "activityIndicator"
            $0.frame = view.frame
            $0.center = view.center
            $0.backgroundColor = UIColor(white: 0, alpha: 0.2)
        }

        let loadingView = UIView()..{
            $0.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
            $0.center = view.center
            $0.backgroundColor = UIColor(white: 0, alpha: 0.4)
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
        }

        let spinner = Spinner()..{
            $0.color = UIColor(white: 1.0, alpha: 0.5)
            $0.lineWidth = 6
            $0.isAnimating = true
            $0.isHidden = false
            $0.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
            $0.center = CGPoint(x: loadingView.frame.size.width / 2, y: loadingView.frame.size.height / 2)
        }

        loadingView.addSubview(spinner)
        container.addSubview(loadingView)
        view.addSubview(container)
    }

    func hideActivityIndicator() {
        view.view(withId: "activityIndicator")?.removeFromSuperview()
    }
}

extension UIViewController {
    func addActionSheetForIpad(actionSheet: UIAlertController) {
        if let popoverPresentationController = actionSheet.popoverPresentationController {
            popoverPresentationController.sourceView = view
            popoverPresentationController.sourceRect = CGRect(x: view.bounds.midX, y: view.bounds.midY, width: 0, height: 0)
            popoverPresentationController.permittedArrowDirections = []
        }
    }
}
