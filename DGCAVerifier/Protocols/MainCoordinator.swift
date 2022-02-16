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
//  MainCoordinator.swift
//  verifier-ios
//
//

import UIKit
import SwiftDGC

protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    var navigationController: UINavigationController { get set }

    func start()
    func dismiss()
    func dismissToRoot()
}

class MainCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        navigationController.setNavigationBarHidden(true, animated: false)
    }

    func start() {
        let controller = HomeViewController(coordinator: self, viewModel: HomeViewModel())
        navigationController.pushViewController(controller, animated: true)
    }
    
    func dismiss() {
        navigationController.popViewController(animated: true)
    }
    
    func dismissToRoot() {
        navigationController.popToRootViewController(animated: true)
    }

}

extension MainCoordinator: HomeCoordinator {
    func showCamera() {
		let cameraViewController = CameraViewController(coordinator: self)
		let controller = HFBackViewController()
		controller.delegate = cameraViewController
        navigationController.pushViewController(controller, animated: true)
    }
    
    func showCountries() {
    }
    
    func openSettings() {
        let vm = SettingsViewModel()
        let controller = SettingsViewController(coordinator: self, viewModel: vm)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        navigationController.pushViewController(controller, animated: true)
    }
	
	func openCustomPicker() {
		let controller = CustomPickerController(coordinator: self)
		controller.modalPresentationStyle = .pageSheet
		navigationController.present(controller, animated: true)
	}
    
    func openDebug() {
        #if DEBUG
        let vm = DebugViewModel()
        let controller = DebugViewController(coordinator: self, viewModel: vm)
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        navigationController.pushViewController(controller, animated: true)
        #endif
    }
}

extension MainCoordinator: CameraCoordinator {
    func validate(payload: String, country: CountryModel?, delegate: CameraDelegate) {
        let vm = VerificationViewModel(payload: payload, country: country)
        let verificationController = VerificationViewController(coordinator: self, delegate: delegate, viewModel: vm)
        verificationController.modalPresentationStyle = .overFullScreen
        verificationController.modalTransitionStyle = .crossDissolve
        let controller = HFBackViewController()
        controller.delegate = verificationController
        controller.modalPresentationStyle = .overFullScreen
        controller.modalTransitionStyle = .crossDissolve
        navigationController.present(controller, animated: true)
    }
}


extension MainCoordinator: VerificationCoordinator {
    func dismissVerification(completion: (()->())?) {
        navigationController.dismiss(animated: true, completion: completion)
    }
}

extension MainCoordinator: SettingsCoordinator {
    func dismissSettings(completion: (() -> ())?) {
        navigationController.popViewController(animated: true)
    }
    
    func openWebURL(url: URL){
        UIApplication.shared.open(url)
    }
}

extension MainCoordinator: CustomPickerCoordinator {
	func dismissCustomPicker(completion: (() -> Void)?) {
		navigationController.popViewController(animated: false)
	}
}

#if DEBUG
extension MainCoordinator: DebugCoordinator {
    func dismissDebugPage(completion: (() -> ())?) {
        navigationController.popViewController(animated: true)
    }
}
#endif
