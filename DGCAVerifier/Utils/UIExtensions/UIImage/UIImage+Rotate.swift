//
//  UIImage+Rotate.swift
//  Verifier
//
//  Created by Andrea Prosseda on 26/07/21.
//

import UIKit

public extension UIImage {
    
    func rotate(radians: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        
        let rect = CGRect(origin: CGPoint.zero, size: size)
        
        let center = CGPoint(x: rect.midX, y: rect.midY)
        
        context.translateBy(x: center.x, y: center.y)
        context.rotate(by: radians)
        context.translateBy(x: -center.x, y: -center.y)
        
        self.draw(in: rect)
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }
    
    func rotate(degree: Int) -> UIImage? {
        let radians = CGFloat(Double(degree) * .pi / 180)
        return rotate(radians: radians)
    }
    
}
