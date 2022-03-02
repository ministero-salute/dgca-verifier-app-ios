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
    @IBOutlet weak var scanModeLabel: AppLabel!
    
    public override init() {
        super.init()
        
        self.backgroundColor = Palette.gray
        
        self.backButton.style = .minimal
        self.backButton.setLeftImage(named: "icon_back")
        
        setUpScanModeLabel()
        
        self.flashButton.cornerRadius = 30.0
        self.flashButton.backgroundColor = .clear
        self.flashButton.setImage(UIImage(named: "flash-camera"))
        self.flashButton.isHidden = Store.getBool(key: .isFrontCameraActive)
    }
    
    private func setUpScanModeLabel() {
        scanModeLabel.uppercased = true
        scanModeLabel.size = 20
        
        let scanMode: String = Store.get(key: .scanMode) ?? ""
        var mode: String = ""
        
        switch scanMode{
        case Constants.scanMode2G:
            mode = "top.bar.scan.mode.2G".localized
        case Constants.scanMode3G:
            mode = "top.bar.scan.mode.3G".localized
        case Constants.scanModeBooster:
            mode = "top.bar.scan.mode.Boster".localized
        case Constants.scanModeSchool:
            mode = "top.bar.scan.mode.Scuola".localized
        case Constants.scanMode50:
            mode = "top.bar.scan.mode.50".localized
        case Constants.scanModeItalyEntry:
                mode = "top.bar.scan.mode.itEntry".localized
        default:
            break
        }
        
        scanModeLabel.text = mode
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
