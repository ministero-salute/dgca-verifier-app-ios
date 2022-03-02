//
//  ButtonBar.swift
//  Verifier
//
//  Created by Johnny Bueti on 09/02/22.
//

import UIKit

class FooterBar: AppView {

    @IBOutlet weak var closeView: UIView!
    @IBOutlet weak var viewLabel: AppLabel!
    @IBOutlet weak var viewImage: UIImageView!
    
    private var onTapCallback: (() -> Void)?
    
    public override init() {
        super.init()
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(invokeCallback))
//        closeView.addGestureRecognizer(tap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func setupTapCallback(callback: @escaping () -> Void) {
        self.onTapCallback = callback
    }
    
    @objc private func invokeCallback() {
        if let cb = self.onTapCallback {
            cb()
        }
    }
    
}
