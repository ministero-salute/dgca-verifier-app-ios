/*
 *  license-start
 *  
 *  Copyright (C) 2021 Ministero della Salute and all other contributors
 *  
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *  
 *      http://www.apache.org/licenses/LICENSE-2.0
 *  
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS,
 *  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *  See the License for the specific language governing permissions and
 *  limitations under the License.
*/

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
