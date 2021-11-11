//
//  ProgressView.swift
//  Verifier
//
//  Created by Andrea Prosseda on 07/09/21.
//

import UIKit

class ProgressView: AppView {
    
    @IBOutlet weak var messageLabel: AppLabel!
    @IBOutlet weak var showMoreLabel: AppLabelUrl!
    @IBOutlet weak var confirmButton: AppButton!
    
    @IBOutlet weak var resumeButton: AppButton!
    @IBOutlet weak var progressInfoLabel: AppLabel!
    @IBOutlet weak var progressInfoSubLabel: AppLabel!
    
    @IBOutlet weak var idleView: UIView!
    @IBOutlet weak var downloadView: UIView!
    @IBOutlet weak var progressView: UIProgressView!
    
    func fillView(with progress: CRLProgress) {
        stop()
        showMoreLabel.fillView(with: .init(text: "home.show.more"))
        messageLabel.text = "crl.update.title".localizeWith(progress.remainingSize)
    }
    
    func downloading(with progress: CRLProgress) {
        start()
        progressView.progress = progress.current
        messageLabel.text = "crl.update.loading.title".localized
        progressInfoLabel.text = progress.chunksMessage
        progressInfoSubLabel.text = progress.downloadedMessage
    }
    
    func pause(with progress: CRLProgress) {
        downloading(with: progress)
        resumeButton.isHidden = false
        messageLabel.text = "crl.update.resume.title".localized
    }
    
    func error(with progress: CRLProgress) {
        downloading(with: progress)
        stop()
        
        messageLabel.isHidden = false
        showMoreLabel.isHidden = false
        confirmButton.isHidden = false
            
        messageLabel.text = "crl.update.title".localizeWith(progress.remainingSize)
    }
    
    private func start() {
        idleView.isHidden = true
        resumeButton.isHidden = true
        downloadView.isHidden = false
        progressView.isHidden = downloadView.isHidden
    }
    
    private func stop() {
        idleView.isHidden = false
        downloadView.isHidden = true
        progressView.isHidden = downloadView.isHidden
    }
    
}
