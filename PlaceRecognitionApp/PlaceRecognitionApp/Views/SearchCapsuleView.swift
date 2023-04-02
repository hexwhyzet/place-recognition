//
//  SearchCapsuleView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 30.10.2022.
//

import Foundation
import UIKit

class SearchCapsuleView: UIView {
    
    // MARK: Building info view
    
    var blurView: UIVisualEffectView?
    
    var buildingInfoView: BuildingInfoView = BuildingInfoView()
    
    // MARK: Stored info
    var storedPlaceRecognition: PlaceRecognition = PlaceRecognition(id: 1, name: "DEMO", description: "DEMO", image: UIImage(named: "sample_building")!, address: "DEMO ADDRESS", metro: "DEMO METRO")
    
    // MARK: Delegates
    
    var delegate: SearchCapsuleDelegate? = nil
    
    var searchIcon = UIImageView()
    
    public var debugButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
    
    var textView: UITextView = UITextView()

    
    var isExpanded = true
    
    var originalLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    var originalTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    var originalBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    var originalHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .bg.withAlphaComponent(0.0)
        searchIcon.image = UIImage(named: "Radar")!
        searchIcon.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(searchIcon)
        NSLayoutConstraint.activate([
            searchIcon.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 40),
            searchIcon.centerYAnchor.constraint(equalTo: self.centerYAnchor),
        ])
        
        self.addSubview(textView)
        textView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: self.topAnchor),
            textView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.leadingAnchor.constraint(equalTo: searchIcon.trailingAnchor)
        ])
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        textView.backgroundColor = .clear
        
        searchIcon.tintColor = .main
        
        // DEBUG
        self.addSubview(debugButton)
        debugButton.translatesAutoresizingMaskIntoConstraints = false
        debugButton.backgroundColor = .blue
        NSLayoutConstraint.activate([
            debugButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -40),
            debugButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.trailingAnchor.constraint(equalTo: debugButton.leadingAnchor),
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setUp
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        // Set up expanded UI elements
        setupExpandedUI()
        
        // Set up tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)
        
        // Set up swipe down gesture recognizer
        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDownGesture.direction = .down
        self.addGestureRecognizer(swipeDownGesture)
    }
    
    func setRadius() {
        var radius = CGFloat(20.0)
        if isExpanded {
            radius = self.frame.height / 2 - 1
        }
        self.layer.cornerRadius = radius
        blurView?.layer.cornerRadius = radius
    }
    
    // MARK: Gestures
    // TODO: Debugs
    @objc func handleTap() {
        print("tapped")
        if !isExpanded {
            expandView(place: storedPlaceRecognition)
        }
    }
    
    @objc func handleSwipeDown() {
        print("swiped")

        if isExpanded {
            collapseView()
        }
    }

    
    // MARK: Page expansion and retraction.
    
    func setupExpandedUI() {
        guard let superview = blurView?.superview else {
            return
        }
        addSubview(buildingInfoView)
        buildingInfoView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            buildingInfoView.topAnchor.constraint(equalTo: blurView!.topAnchor),
            buildingInfoView.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor),
            buildingInfoView.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor),
        ])
        buildingInfoView.isHidden = true
        buildingInfoView.alpha = 0.0
    }
    
    func expandView(place: PlaceRecognition) {
        let favouritePlaces = UserDefaults.standard.array(forKey: "Favourite places") as? [Int64]
        if favouritePlaces == nil {
            UserDefaults.standard.set([Int](),forKey: "Favourite places")
        }
        // Set the image, title, and description
        buildingInfoView.updateHostingView(place: place, is_fav: favouritePlaces!.contains(place.id))
        
        storedPlaceRecognition = place
        
        changeConstraint()
        buildingInfoView.isHidden = false

        self.searchIcon.isHidden = false
        self.textView.isHidden = false
        self.debugButton.isHidden = false
        
        // Animate the expansion
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut,  animations: { [self] in
            // Show expanded UI elements
            self.changeVisability()
            self.blurView?.superview?.layoutIfNeeded()
            self.setRadius()
        }) { _ in
            self.changeHiddenStatus()
            self.delegate?.viewExpanded()
            self.isExpanded = true
        }
    }
    
    func changeHiddenStatus() {
        buildingInfoView.isHidden = isExpanded
        
        // Hide original UI elements
        self.searchIcon.isHidden = !isExpanded
        self.textView.isHidden = !isExpanded
        self.debugButton.isHidden = !isExpanded
    }
    
    func changeVisability() {
        buildingInfoView.alpha = isExpanded ? 0.0 : 1.0
        self.backgroundColor = isExpanded ? .bg.withAlphaComponent(0.0) : .bg.withAlphaComponent(1.0)
        self.searchIcon.alpha = !isExpanded ? 0.0 : 1.0
        self.textView.alpha = !isExpanded ? 0.0 : 1.0
        self.debugButton.alpha = !isExpanded ? 0.0 : 1.0
    }
    
    func changeConstraint() {
        guard let blurView = blurView else { return }
        guard let superview = blurView.superview else { return }
        NSLayoutConstraint.deactivate([
            originalBottomConstraint,
            originalHeightConstraint,
            originalTrailingConstraint,
            originalLeadingConstraint
        ])
        if isExpanded {
            originalBottomConstraint = blurView.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            originalHeightConstraint = blurView.heightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15)
            originalTrailingConstraint.constant = -15
            originalLeadingConstraint.constant = 15
        } else {
            originalBottomConstraint = blurView.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            originalHeightConstraint = blurView.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 1)
            originalTrailingConstraint.constant = 0
            originalLeadingConstraint.constant = 0
            
        }
        NSLayoutConstraint.activate([
            originalBottomConstraint,
            originalHeightConstraint,
            originalTrailingConstraint,
            originalLeadingConstraint
        ])
    }
    
    func collapseView() {
        self.translatesAutoresizingMaskIntoConstraints = false
        
        changeConstraint()
        buildingInfoView.isHidden = false
    
        self.searchIcon.isHidden = false
        self.textView.isHidden = false
        self.debugButton.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:{
            self.changeVisability()
            self.blurView?.superview?.layoutIfNeeded()
            self.setRadius()
        }) { _ in
            self.changeHiddenStatus()
            self.delegate?.viewCollapsed()
            self.isExpanded = false
        }
    }
}
