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
    
    
    private let originThickness: CGFloat = 10.0
    private var animTargetThickness: CGFloat = 10.0
    private var animInitialThickness: CGFloat = 10.0
    private var animationDuration: TimeInterval = 0.3
    private var startTime: TimeInterval?
    private var displayLink: CADisplayLink?
    private var thickness: CGFloat = 10.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private let confirmColor: UIColor = .systemGreen
    private var animTargetColor: UIColor = .black
    private var animInitialColor: UIColor = .black
    var circleColor: UIColor = .secondary {
            didSet {
                setNeedsDisplay()
            }
        }
    
    private var isAnimating = false
            
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
        context.setStrokeColor(circleColor.cgColor)
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
                
        if (angleX == 0.0 && angleY == 0.0){
            isAnimating = false
            thickness += 0.1
            thickness = thickness < 0 ? 0 : thickness
            thickness = thickness > (bounds.width / 2) ? (bounds.width / 2) : thickness
            circleColor = UIColor.secondary.interpolate(to: confirmColor, progress: CGFloat(min(thickness / (bounds.width / 2), 1)))
        } else if !isAnimating{
            isAnimating = true
            animateThickness(to: 10, color: .secondary, duration: 0.3)
        }
        prevAngleX = angleX
        prevAngleY = angleY
                
        let rotationX = CATransform3DRotate(identity, -angleX, 1.0, 0.0, 0.0)
        let rotationY = CATransform3DRotate(identity, -angleY, 0.0, 1.0, 0.0)

        self.layer.transform = CATransform3DConcat(rotationX, rotationY)
    }
    
    // MARK: Cursor thickness animation
    
    func animateThickness(to newThickness: CGFloat, color: UIColor, duration: TimeInterval = 0.5) {
            animInitialThickness = thickness
            animTargetThickness = newThickness
            animInitialColor = circleColor
            animTargetColor = color
            animationDuration = duration

            startTime = nil

            displayLink?.invalidate()
            displayLink = CADisplayLink(target: self, selector: #selector(updateThickness))
            displayLink?.add(to: .current, forMode: .default)
        }

    @objc private func updateThickness(displayLink: CADisplayLink) {
            if startTime == nil {
                startTime = displayLink.timestamp
            }
            let elapsed = displayLink.timestamp - startTime!
            let progress = min(elapsed / animationDuration, 1)
            
            thickness = animInitialThickness + (animTargetThickness - animInitialThickness) * CGFloat(progress)
            
            circleColor = animInitialColor.interpolate(to: animTargetColor, progress: CGFloat(progress))
        
            if progress >= 1 {
                displayLink.invalidate()
                self.displayLink = nil
            }
    }
}


