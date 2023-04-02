//
//  ViewController.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 20.10.2022.
//

import UIKit
import ARKit

class ViewController: UIViewController {
    
    /// Search capsule view, to view info about building
    private var searchCapsule = SearchCapsuleView()
    
    private var blurView = UIVisualEffectView()
    
    /// Ar view to get snapshot.
    private var arView = ARSCNView()
        
    /// Cursor view shows dynamic rotation of device
    private var cursorView = CursorView()
    
    /// Ar world configuration
    private let configuration = ARWorldTrackingConfiguration()
    
    /// Place recognizer, to get recognize the building
    let placeRecognizer: PlaceRecognizer = LocalPlaceRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.backgroundColor = .bg
        view.addSubview(arView)
        setArView()
        
        setSearchCapsule()
        
        // Place recognizer set up
        (placeRecognizer as! LocalPlaceRecognizer).delegate = self
        (placeRecognizer as! LocalPlaceRecognizer).completeDelegate = cursorView
        searchCapsule.delegate = cursorView
    }
    
    
    func setArView() {
        // ArView setup
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
        
        // Cursor setup
        cursorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cursorView.centerXAnchor.constraint(equalTo: arView.centerXAnchor),
            cursorView.centerYAnchor.constraint(equalTo: arView.centerYAnchor),
            cursorView.heightAnchor.constraint(equalToConstant: self.view.frame.height / 9),
            cursorView.widthAnchor.constraint(equalToConstant: self.view.frame.height / 9)
        ])
        view.layoutIfNeeded()
        cursorView.setUpCheckmark()
        cursorView.delegate = placeRecognizer as? LocalPlaceRecognizer
    }
    
    func setSearchCapsule() {
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.systemChromeMaterial)
        blurView = UIVisualEffectView(effect: blurEffect)
        blurView.translatesAutoresizingMaskIntoConstraints = false
        arView.addSubview(blurView)

        let originalBottomConstraint = blurView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        let originalHeightConstraint = blurView.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15)
        let originalTrailingConstraint = blurView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        let originalLeadingConstraint = blurView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15)
        NSLayoutConstraint.activate([
            originalBottomConstraint,
            originalHeightConstraint,
            originalTrailingConstraint,
            originalLeadingConstraint
        ])
        
        searchCapsule.originalBottomConstraint = originalBottomConstraint
        searchCapsule.originalHeightConstraint = originalHeightConstraint
        searchCapsule.originalLeadingConstraint = originalLeadingConstraint
        searchCapsule.originalTrailingConstraint = originalTrailingConstraint
        searchCapsule.blurView = blurView

        blurView.contentView.addSubview(searchCapsule)
        searchCapsule.translatesAutoresizingMaskIntoConstraints = false
        // Constraints for contentViewSubview
        NSLayoutConstraint.activate([
            searchCapsule.leadingAnchor.constraint(equalTo: blurView.contentView.leadingAnchor),
            searchCapsule.trailingAnchor.constraint(equalTo: blurView.contentView.trailingAnchor),
            searchCapsule.topAnchor.constraint(equalTo: blurView.contentView.topAnchor),
            searchCapsule.bottomAnchor.constraint(equalTo: blurView.contentView.bottomAnchor)
        ])
        blurView.layer.masksToBounds = true
        searchCapsule.debugButton.addTarget(self, action: #selector(alert), for: .touchUpInside)
        searchCapsule.layer.zPosition = cursorView.layer.zPosition + 100
    }
    
    /// Update section
    
    func getResultFromPhotoToPlaceRecognizer(image: UIImage) async -> PlaceRecognition {
        return try! await placeRecognizer.recognize(image: image)
    }
    
    /// Update the textView in searchCapsule
    func updateCapsuleView(placeRecognition: PlaceRecognition) {
        // TODO: Just for debug
        searchCapsule.textView.text = placeRecognition.description
    }
    
    // DEBUG
    @objc func alert() {
        Task {
            let place = await self.getResultFromPhotoToPlaceRecognizer(image: self.arView.snapshot())
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
        blurView.layer.cornerRadius = blurView.frame.height / 2 - 1
        searchCapsule.isExpanded = false
        cursorView.cursorMotionInitialization(handler: cursorView.bindMotion)
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

extension ViewController: PlaceRecognizerDelegate {
    
    func getSnapshot() -> UIImage {
        return self.arView.snapshot()
    }
    
    func showPlaceRecognition(recognition: PlaceRecognition) -> Task<Void, Error> {
        return Task {
            print("Show place recognition")
            try await Task.sleep(nanoseconds: 500000000)
            searchCapsule.expandView(place: recognition)
            updateCapsuleView(placeRecognition: recognition)
        }
    }
    
}


