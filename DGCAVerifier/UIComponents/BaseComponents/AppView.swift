//
//  AppView.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import UIKit

class AppView: UIView {
    
    func xibSetup() {
        let view : UIView = loadViewFromNib()
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
        view.backgroundColor = .clear
        self.backgroundColor = .clear
        setup()
    }
    
    public init() {
        super.init(frame: CGRect(origin: .zero, size: CGSize(width: 100, height: 100)))
        self.xibSetup()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.xibSetup()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.xibSetup()
    }
    
    @objc open func setup() {}

    func loadViewFromNib() -> UIView {
        let bundle = Bundle(for: type(of: self))
        let nibName = String(describing: type(of: self))
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        return view
    }
}
