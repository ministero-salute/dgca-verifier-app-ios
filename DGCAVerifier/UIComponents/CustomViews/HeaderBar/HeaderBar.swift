//
//  HeaderBar.swift
//  Verifier
//
//  Created by Johnny Bueti on 08/02/22.
//

import Foundation
import UIKit

class HeaderBar: AppView {
	
	@IBOutlet weak var flashButton: AppButton!
	@IBOutlet weak var backButton: AppButton!
	@IBOutlet weak var switchCameraButton: UIButton!

	public override init() {
		super.init()
		
		self.backButton.style = .minimal
		self.backButton.setLeftImage(named: "icon_back")
		
		self.flashButton.cornerRadius = 30.0
		self.flashButton.backgroundColor = .clear
		self.flashButton.setImage(UIImage(named: "flash-camera"))
		self.flashButton.isHidden = Store.getBool(key: .isFrontCameraActive)
	}
	
	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
