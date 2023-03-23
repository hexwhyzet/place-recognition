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
    
    var thickness: CGFloat = 5.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isAnimating = false
    
    var scaleFactor = 1.0
    
    var cursorImageView = UIImageView()
    
    var transformation: CATransform3D {
        get {
            return layer.transform
        }
        set(newVal) {
            layer.transform = newVal
        }
    }
    
    // Add low-pass filter properties
    private let filterFactor: Double = 0.08
    private var prevAngleX: Double = 0
    private var prevAngleY: Double = 0
    
    private let dampingFactor: Double = 0.99
    
    let motionManager : CMMotionManager = CMMotionManager()

    
    // MARK: Initialization
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
    
    
    override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        // Set the circle's center and radius
        let center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        let radius = min(bounds.width, bounds.height) / 2

        // Set the stroke color and thickness
        context.setStrokeColor(UIColor.black.cgColor)
        context.setLineWidth(thickness)
        
        // Create and draw the circle
        let circlePath = UIBezierPath(arcCenter: center, radius: radius - thickness / 2, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
        context.addPath(circlePath.cgPath)
        context.strokePath()
    }
    
    
    // MARK: Cursor motion
    public func cursorMotionInitialization(handler: @escaping CMDeviceMotionHandler) {
        motionManager.deviceMotionUpdateInterval = 0.008
        motionManager.startDeviceMotionUpdates(to: OperationQueue.main, withHandler: handler)
    }
    
    ///DEBUG
    var maxAngle: (Double, Double) = (0, 0)
    
    let angleMaxThreshold: (Double, Double) = (60 * .pi / 180, 60 * .pi / 180)
    
    let angleMinThreshold: (Double, Double) = (2 * .pi / 180, 2 * .pi / 180)

    
    func bindMotion(data: CMDeviceMotion?, error: Error?) {
        var identity = CATransform3DIdentity
        identity.m34 = -1 / 300
        guard let data = data, error == nil else {
                    return
                }
        
        var angleX = -data.rotationRate.x
        var angleY = data.rotationRate.y
        
        angleX = prevAngleX * (1 - filterFactor) + angleX * filterFactor
        angleY = prevAngleY * (1 - filterFactor) + angleY * filterFactor
        
        angleX *= dampingFactor
        angleY *= dampingFactor
        
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
        
        var scale = CATransform3DMakeScale(1.0, 1.0, 1.0)
        
        if (prevAngleX == 0 && prevAngleY == 0 && angleX == 0.0 && angleY == 0.0){
            isAnimating = false
            scaleFactor -= 0.005
            scaleFactor = scaleFactor < 0 ? 0 : scaleFactor
            scale = CATransform3DMakeScale(scaleFactor, scaleFactor, 1.0)
        } else if !isAnimating{
            UIView.animate(withDuration: 0.3) {
                print("Returned to origin")
                self.scaleFactor = 1
                scale = CATransform3DMakeScale(self.scaleFactor, self.scaleFactor, 1.0)
                self.layer.transform = scale
            }
            isAnimating = true
        }
        
        prevAngleX = angleX
        prevAngleY = angleY
                
        let rotationX = CATransform3DRotate(identity, -angleX, 1.0, 0.0, 0.0)
        let rotationY = CATransform3DRotate(identity, -angleY, 0.0, 1.0, 0.0)

        self.layer.transform = CATransform3DConcat(CATransform3DConcat(rotationX, rotationY), scale)
    }
}


