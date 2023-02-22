//
//  CursorView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import UIKit
import CoreMotion

class CursorView: UIView {
    
    var cursorImageView = UIImageView()
    
    var transformation: CATransform3D {
        get {
            return layer.transform
        }
        set(newVal) {
            layer.transform = newVal
        }
    }
    
    let motionManager : CMMotionManager = CMMotionManager()

    override init(frame: CGRect)  {
        super.init(frame: frame)
        self.frame = CGRect(x: 0, y: 0, width: 700, height: 700)
        self.backgroundColor = UIColor(white: 1, alpha: 0.0)
        cursorImageView.image = UIImage(named: "Cursor")
        cursorImageView.tintColor = .main
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
        
        cursorMotionInitialization(handler: bindMotion)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func cursorMotionInitialization(handler: @escaping CMDeviceMotionHandler) {
        motionManager.deviceMotionUpdateInterval = 0.008
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    ///DEBUG
    var maxAngle: (Double, Double) = (0, 0)
    
    let angleMaxThreshold: (Double, Double) = (40 * .pi / 180, 40 * .pi / 180)
    
    let angleMinThreshold: (Double, Double) = (5 * .pi / 180, 5 * .pi / 180)

    
    func bindMotion(data: CMDeviceMotion?, error: Error?) {
        var identity = CATransform3DIdentity
        identity.m34 = -1 / 300
        guard let data = data, error == nil else {
                    return
                }
        
        var angleX = -data.rotationRate.x
        var angleY = data.rotationRate.y
        
        if abs(angleX) < angleMinThreshold.0 {
            angleX = 0
        }

        if abs(angleY) < angleMinThreshold.1 {
            angleY = 0
        }
         
        if abs(angleX) > angleMaxThreshold.0 {
            angleX = copysign(angleMaxThreshold.0 , angleX)
        }
        
        if abs(angleY) > angleMaxThreshold.1 {
            angleY = copysign(angleMaxThreshold.1 , angleY)
        }
        print(angleX, angleY, separator: "; ")
            
        let rotationX = CATransform3DRotate(identity, angleX, 1.0, 0.0, 0.0)
        let rotationY = CATransform3DRotate(identity, angleY, 0.0, 1.0, 0.0)

        self.transformation = CATransform3DConcat(rotationX, rotationY)
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


