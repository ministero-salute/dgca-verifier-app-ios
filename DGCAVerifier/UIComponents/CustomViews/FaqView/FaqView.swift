//
//  FaqView.swift
//  Verifier
//
//  Created by Andrea Prosseda on 27/07/21.
//

import Foundation

class FaqView: AppView {
    
    @IBOutlet weak var titleLabel: AppLabelUrl!

    func fillView(with content: AppLabelUrl.Content) {
        titleLabel.fillView(with: content)
    }
}
