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
//  AppButton.swift
//  VerificaC19
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

class AppButton: UIButton {
    
    let CORNER_RADIUS: CGFloat = 4
    let EDGE_INSET: CGFloat = 8
    let TITLE_INSET: CGFloat = 16
    
    var style: ButtonStyle = .blue { didSet { initialize() } }
    
    override var isEnabled: Bool { didSet { setEnabled() } }
        
    override public init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
        restoreInsets()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
        restoreInsets()
    }
    
    internal func initialize() {
        contentHorizontalAlignment = .left
        titleLabel?.font = Font.getFont(size: 14, style: .bold)
		titleLabel?.textColor = style.tintColor
        backgroundColor = style.backgroundColor
        tintColor = style.tintColor
        cornerRadius = CORNER_RADIUS
        setBorders()
        setConstraints()
    }
    
    private func setBorders() {
        guard style.hasBorder else { return removeBorder() }
        setBorder(color: style.tintColor, cornerRadius: CORNER_RADIUS)
    }
    private func setConstraints() {
        setHeightConstraint()
        setCompressionResistance()
    }

    private func setEnabled() {
        DispatchQueue.main.async { [weak self] in
            UIView.animateKeyframes (
                withDuration: 0.2,
                delay: 0, options: .calculationModeLinear,
                animations: { [weak self] in self?.initialize() },
                completion: nil
            )
        }
    }
    
    func setRightImage(named name: String) {
        setRightImage(name.image)
    }
    
    func setRightImage(_ image: UIImage?) {
        removeImages()
        guard let image = getImage(image) else { return }
//        guard let label = titleLabel else { return }
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            view.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 0)
        ])

    }
    
    func setLeftImage(named name: String) {
        setLeftImage(name.image)
    }
    
    func setLeftImage(_ image: UIImage?) {
        removeImages()
        guard let image = getImage(image) else { return }
        guard let label = titleLabel else { return }
        let view = UIImageView(image: image)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        
        NSLayoutConstraint.activate([
            view.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            view.centerYAnchor.constraint(equalTo: label.centerYAnchor, constant: 0)
        ])
        
        contentEdgeInsets = .init(top: 0, left: EDGE_INSET, bottom: 0, right: EDGE_INSET)
        titleEdgeInsets = .init(top: 0, left: EDGE_INSET, bottom: 0, right: EDGE_INSET)
        
    }
    private func removeImages() {
        restoreInsets()
        subviews
            .compactMap { $0 as? UIImageView }
            .forEach { $0.removeFromSuperview() }
    }
    
    private func setHeightConstraint() {
        let height = self.heightAnchor.constraint(equalToConstant: 60 * Font.scaleFactor)
        height.priority = .init(800)
        NSLayoutConstraint.activate([height])
    }
    
    private func setCompressionResistance() {
        setContentCompressionResistancePriority(.init(800), for: .vertical)
        setContentCompressionResistancePriority(.init(1000), for: .horizontal)
    }
 
    private func getImage(_ image: UIImage?) -> UIImage? {
        guard let image = image else { return nil }
        switch style {
        case .blue:     return image.white
        case .disabled: return image.white
        default:        return image.blue
        }
    }

    public func restoreInsets() {
        contentEdgeInsets = .init(top: 0, left: TITLE_INSET, bottom: 0, right: TITLE_INSET)
        titleEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 0)
    }
    
}
