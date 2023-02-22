//
//  ViewController.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 20.10.2022.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    private var searchCapsule = SearchCapsuleView()
    
    private var arView = ARSCNView()
    
    private let configuration = ARWorldTrackingConfiguration()
    
    private var cursorView = CursorView()
    
    let placeRecognizer: PlaceRecognizer = LocalPlaceRecognizer()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(arView)
        view.addSubview(searchCapsule)
        view.backgroundColor = .bg
        setArView()
        setSearchCapsule()
        
    }
    
    /// Set section
    
    func setArView() {
        arView.translatesAutoresizingMaskIntoConstraints = false
        arView.showsStatistics = true
        arView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        NSLayoutConstraint.activate([
            arView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            arView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            arView.topAnchor.constraint(equalTo: view.topAnchor),
        ])
        arView.addSubview(cursorView)
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cursorView.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            cursorView.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            cursorView.heightAnchor.constraint(equalToConstant: 130),
            cursorView.widthAnchor.constraint(equalToConstant: 130)
        ])
    }
    
    func setSearchCapsule() {
        searchCapsule.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchCapsule.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            searchCapsule.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15),
            searchCapsule.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            searchCapsule.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
        ])
        // DEBUG
        searchCapsule.debugButton.addTarget(self, action: #selector(alert), for: .touchUpInside)
    }
        
    /// Update section
    
    func getResultFromPhotoToPlaceRecognizer(image: UIImage) async -> PlaceRecognition {
        return try! await placeRecognizer.recognize(image: image)
    }
    
    /// Update the textView in searchCapsule
    func updateCapsuleView(placeRecognition: PlaceRecognition) {
        searchCapsule.textView.text = placeRecognition.description
    }
    
    // DEBUG
    @objc func alert() {
        print("Pressed")
        Task {
            let place = await self.getResultFromPhotoToPlaceRecognizer(image: self.arView.snapshot())
            updateCapsuleView(placeRecognition: place)
            let alert = UIAlertController(title: "Alert", message: place.description, preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                                        switch action.style{
                                            case .default:
                                            print("default")
                                            
                                            case .cancel:
                                            print("cancel")
                                            
                                            case .destructive:
                                            print("destructive")
                                            
                                        @unknown default:
                                            fatalError()
                                        }
                                    }))
                                    self.present(alert, animated: true, completion: nil)
            }
    }
    
//    func bindMotion(data: CMDeviceMotion?, error: Error?) {
//        var identity = CATransform3DIdentity
//        identity.m34 = -1 / 500.0
//
//        let horizontal_minimum = CATransform3DRotate(identity, (-80 * .pi) / 180.0, 0.0, 1.0, 0.0)
//        let horizontal_maximum = CATransform3DRotate(identity, (80 * .pi) / 180.0, 0.0, 1.0, 0.0)
//
//        let vertical_minimum = CATransform3DRotate(identity, (-80 * .pi) / 180.0, 1.0, 0.0, 0.0)
//        let vertical_maximum = CATransform3DRotate(identity, (80 * .pi) / 180.0, 1.0, 0.0, 0.0)
//
//        self.layer.transform = identity
//
//        let horizontal = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: .tiltAlongHorizontalAxis)
//        horizontal.minimumRelativeValue = horizontal_minimum
//        horizontal.maximumRelativeValue = horizontal_maximum
//
//        let vertical = UIInterpolatingMotionEffect(keyPath: "layer.transform", type: .tiltAlongVerticalAxis)
//        vertical.minimumRelativeValue = vertical_minimum
//        vertical.maximumRelativeValue = vertical_maximum
//
//        let group = UIMotionEffectGroup()
//        group.motionEffects = [horizontal, vertical]
//        self.addMotionEffect(group)
//    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        view.layoutIfNeeded()
        searchCapsule.setRadius()
    }
   
    override func viewWillDisappear(_ animated: Bool) {
          super.viewWillDisappear(animated)
          self.arView.session.pause()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        get {
            return .portrait
        }
    }
}

