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
        view.backgroundColor = .bg
        view.addSubview(arView)
        setArView()
        
        arView.addSubview(searchCapsule)
        setSearchCapsule()
        searchCapsule.layer.zPosition = cursorView.layer.zPosition + 100

        
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.arView.session.run(configuration)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchCapsule.setRadius()
        searchCapsule.isExpanded = false
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

