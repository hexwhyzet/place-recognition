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


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        view.addSubview(arView)
        view.addSubview(searchCapsule)
        view.backgroundColor = .bg
        setArView()
        setSearchCapsule()
        
    }
    
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
    }
    
    func setSearchCapsule() {
        searchCapsule.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            searchCapsule.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            searchCapsule.heightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15),
            searchCapsule.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -15),
            searchCapsule.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 15),
        ])
    }
    
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

