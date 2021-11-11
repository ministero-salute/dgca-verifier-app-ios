//
//  UIApplication+TopViewController.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import UIKit

public extension UIApplication {
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = base as? UINavigationController {
            return topViewController(base: navigationController.visibleViewController)
        }
        
        if let tabBarController = base as? UITabBarController {
            if let selected = tabBarController.selectedViewController {
                return topViewController(base: selected)
            }
        }
        
        if let presentedViewController = base?.presentedViewController {
            return topViewController(base: presentedViewController)
        }
        
        return base
    }
    
    static func showAppAlert(content: AlertContent) -> Void {
        guard let topVC = UIApplication.topViewController() else { return }
        AppAlertViewController.present(for: topVC, with: content)
    }
    
}
