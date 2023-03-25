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
    
    // Delegates
    
    var delegate: CursorStabilizationDelegate?
    
    // CheckMark
    
    let checkMarkView: CheckmarkView = CheckmarkView()
    
    var isCheckmarked: Bool = false
    
    var isSendedToRecognize: Bool = false
    
    var isRecognitionComplete: Bool = false
    
    // Thickness
    private let thicknesStep = 0.2
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
    
    // Colors
    private let confirmColor: UIColor = .systemGreen
    private var animTargetColor: UIColor = .black
    private var animInitialColor: UIColor = .black
    var circleColor: UIColor = .secondary {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var isMoving = false
    
    // 3D transformation
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
        self.addSubview(self.checkMarkView)
        checkMarkView.isHidden = true
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
        var currentThicknessStep = thicknesStep
        let stabilizationOverallProcess = thickness / (bounds.width / 2)
        if (angleX == 0.0 && angleY == 0.0){
            isMoving = false
            
            if thickness <= originThickness {
                // If thickness less than original, return to original
                thickness = originThickness
                isSendedToRecognize = false
            } else if stabilizationOverallProcess >= 0.3 && stabilizationOverallProcess <= 0.35 && !isSendedToRecognize {
                // If thickness in start stabilizaton range, send delegate
                delegate?.cursorStabilized()
                isSendedToRecognize = true
            } else if stabilizationOverallProcess >= 0.6 && stabilizationOverallProcess <= 0.95 && !isCheckmarked {
                if isRecognitionComplete {
                    animateThickness(to: bounds.width / 2, color: confirmColor, duration: 0.2)
                    isRecognitionComplete = false
                } else {
                    currentThicknessStep = 0.02
                }
                // If thickness in end of stabilization range, and dont get answer, slow the thickness step
            } else if thickness > (bounds.width / 2) && !isCheckmarked {
                // if thickness greater than max, animate checkmark
                isCheckmarked = true
                thickness = bounds.width / 2
                checkMarkView.isHidden = false
                checkMarkView.animateCheckmark()
            } else if thickness > (bounds.width / 2) {
                thickness = bounds.width / 2
            }
            // Add thickness
            thickness += currentThicknessStep
            circleColor = UIColor.secondary.interpolate(to: confirmColor, progress: CGFloat(min(thickness / (bounds.width / 2), 1)))
        } else if !isMoving{
            isCheckmarked = false
            delegate?.cursorUnstabilized()
            checkMarkView.isHidden = true
            isMoving = true
            animateThickness(to: 10, color: .secondary, duration: 0.3)
        }
        prevAngleX = angleX
        prevAngleY = angleY
        
        let rotationX = CATransform3DRotate(identity, -angleX, 1.0, 0.0, 0.0)
        let rotationY = CATransform3DRotate(identity, -angleY, 0.0, 1.0, 0.0)
        
        self.layer.transform = CATransform3DConcat(rotationX, rotationY)
    }
    
    // MARK: Cursor thickness and color animation
    
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
    
    // MARK: CheckMark animation
    func setUpCheckmark() {
        checkMarkView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checkMarkView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            checkMarkView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            checkMarkView.heightAnchor.constraint(equalToConstant: self.bounds.height),
            checkMarkView.widthAnchor.constraint(equalToConstant: self.bounds.height)
        ])
    }
}

// MARK: Place recognition completed
extension CursorView: PlaceRecognizerCompleteDelegate {
    func recognitionCompleted() {
        isRecognitionComplete = true
        print("Completed")
    }
    
    
}

extension CursorView: SearchCapsuleDelegate {
    func viewCollapsed() {
        cursorMotionInitialization(handler: bindMotion)
        self.isHidden = false
    }
    
    func viewExpanded() {
        self.delegate?.cursorUnstabilized()
        motionManager.stopDeviceMotionUpdates()
        self.isHidden = true
    }
    
    
}

// MARK: Class checkMark

class CheckmarkView: UIView {
    
    private let checkmarkLayer = CAShapeLayer()
    
    var checkmarkColor: UIColor = .main {
        didSet {
            checkmarkLayer.strokeColor = checkmarkColor.cgColor
        }
    }
    
    var animationDuration: CFTimeInterval = 0.5
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCheckmarkLayer()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCheckmarkLayer()
    }
    
    private func setupCheckmarkLayer() {
        backgroundColor = .clear
        checkmarkLayer.strokeColor = checkmarkColor.cgColor
        checkmarkLayer.lineWidth = 6.0
        checkmarkLayer.lineCap = .round
        checkmarkLayer.lineJoin = .round
        checkmarkLayer.fillColor = UIColor.clear.cgColor
        layer.addSublayer(checkmarkLayer)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        checkmarkLayer.path = createCheckmarkPath().cgPath
    }
    
    private func createCheckmarkPath() -> UIBezierPath {
        let path = UIBezierPath()
        
        let startPoint = CGPoint(x: bounds.width * 0.25, y: bounds.height * 0.6)
        let midPoint = CGPoint(x: bounds.width * 0.45, y: bounds.height * 0.8)
        let endPoint = CGPoint(x: bounds.width * 0.75, y: bounds.height * 0.3)
        
        path.move(to: startPoint)
        path.addLine(to: midPoint)
        path.addLine(to: endPoint)
        
        return path
    }
    
    func animateCheckmark() {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1
        animation.duration = animationDuration
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        checkmarkLayer.strokeEnd = 1
        checkmarkLayer.add(animation, forKey: "checkmarkAnimation")
    }
}
