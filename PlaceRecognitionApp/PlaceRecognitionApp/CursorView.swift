//
//  CursorView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import UIKit

class CursorView: UIView {
    
    var cursorImageView = UIImageView()

    override init(frame: CGRect)  {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 700, height: 700)
        self.backgroundColor = UIColor(white: 1, alpha: 0.5)
        cursorImageView.image = UIImage(named: "Cursor")
        self.addSubview(cursorImageView)
        cursorImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cursorImageView.topAnchor.constraint(equalTo: self.topAnchor),
            cursorImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            cursorImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            cursorImageView.bottomAnchor.constraint(equalTo: self.bottomAnchor),

            cursorImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cursorImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func rotateBy() {
        let radians = CGFloat(30 * Double.pi / 180)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseIn],
                       animations: {
            let yRotation = CATransform3DMakeRotation(radians, 0, 1, 0)
            self.layer.transform = CATransform3DConcat(self.layer.transform, yRotation)
        })
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseOut],
                       animations: {
            let yRotation = CATransform3DMakeRotation(-radians, 0, 1, 0)
            self.layer.transform = CATransform3DConcat(self.layer.transform, yRotation)
        })
    }
}




