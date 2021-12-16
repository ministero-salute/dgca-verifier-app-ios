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
    
    func fillView(with progress: DRLProgress) {
        stop()
        showMoreLabel.fillView(with: .init(text: "home.show.more"))
        messageLabel.text = "drl.update.title".localizeWith(progress.remainingSize)
    }
    
    func downloading(with progress: DRLProgress) {
        start()
        progressView.progress = progress.current
        messageLabel.text = "drl.update.loading.title".localized
        progressInfoLabel.text = progress.chunksMessage
        progressInfoSubLabel.text = progress.downloadedMessage
    }
    
    func pause(with progress: DRLProgress) {
        downloading(with: progress)
        resumeButton.isHidden = false
        messageLabel.text = "drl.update.resume.title".localized
    }
    
    func error(with progress: DRLProgress, noSize: Bool = false) {
        downloading(with: progress)
        stop()
        
        messageLabel.isHidden = false
        showMoreLabel.isHidden = noSize
        confirmButton.isHidden = false
            
        messageLabel.text = (noSize ? "drl.update.title.no.size" : "drl.update.title").localizeWith(progress.remainingSize)
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
