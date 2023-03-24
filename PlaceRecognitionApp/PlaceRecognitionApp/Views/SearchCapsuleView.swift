//
//  SearchCapsuleView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 30.10.2022.
//

import Foundation
import UIKit

class SearchCapsuleView: UIView {
    
    // MARK: Stored info
    
    var storedImage: UIImage? = nil
    
    var storedDescription: String = ""
    
    var storedTitle: String = ""
    
    // MARK: Delegates
    
    var delegate: SearchCapsuleDelegate? = nil
    
    var searchIcon = UIImageView()
    
    public var debugButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
    
    var textView: UITextView = UITextView()
    
    var expandedImage = UIImageView()
    var titleLabel = UILabel()
    var descriptionLabel = UITextView()
       
    var isExpanded = true
            
    var originalLeadingConstraint: NSLayoutConstraint = NSLayoutConstraint()
    
    var originalTrailingConstraint: NSLayoutConstraint = NSLayoutConstraint()

    var originalBottomConstraint: NSLayoutConstraint = NSLayoutConstraint()

    var originalHeightConstraint: NSLayoutConstraint = NSLayoutConstraint()

    // MARK: init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .secondary
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
        
        // Set up tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        self.addGestureRecognizer(tapGesture)

        // Set up expanded UI elements
        setupExpandedUI()
        
        self.translatesAutoresizingMaskIntoConstraints = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: setUp

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        guard let superview = superview else { return }
                    
        originalBottomConstraint = self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        originalHeightConstraint = self.heightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15)
        originalTrailingConstraint = self.trailingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.trailingAnchor, constant: -15)
        originalLeadingConstraint = self.leadingAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.leadingAnchor, constant: 15)
    
        NSLayoutConstraint.activate([
            originalBottomConstraint,
            originalHeightConstraint,
            originalTrailingConstraint,
            originalLeadingConstraint
        ])
    }
    
    func setRadius() {
        var radius = CGFloat(0.0)
        if isExpanded {
            radius = self.frame.height / 2 - 1
        }
        self.layer.cornerRadius = radius
    }
    
    // MARK: Gestures
    
    @objc func handleTap() {
        if isExpanded {
            collapseView()
        } else {
            let image: UIImage = storedImage ?? UIImage(named: "sample_building")!
            expandView(
                image: image,
                title: storedTitle,
                description: storedDescription)
        }
    }
    
    // MARK: Page expansion and retraction.
    
    func setupExpandedUI() {
        descriptionLabel.isUserInteractionEnabled = false
        descriptionLabel.isEditable = false
        descriptionLabel.backgroundColor = .clear
        
        expandedImage.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
            
        expandedImage.isHidden = true
        titleLabel.isHidden = true
        descriptionLabel.isHidden = true
        
        expandedImage.alpha = 0.0
        titleLabel.alpha = 0.0
        descriptionLabel.alpha = 0.0
            
        addSubview(expandedImage)
        addSubview(titleLabel)
        addSubview(descriptionLabel)
        
        NSLayoutConstraint.activate([
                expandedImage.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
                expandedImage.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor),
                expandedImage.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor),
                expandedImage.heightAnchor.constraint(equalTo: self.safeAreaLayoutGuide.heightAnchor, multiplier: 0.3),
                
                titleLabel.topAnchor.constraint(equalTo: expandedImage.bottomAnchor, constant: 10),
                titleLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                titleLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                
                descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
                descriptionLabel.leadingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.leadingAnchor, constant: 20),
                descriptionLabel.trailingAnchor.constraint(equalTo: self.safeAreaLayoutGuide.trailingAnchor, constant: -20),
                descriptionLabel.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor, constant: 0)
            ])
    }

    func expandView(image: UIImage, title: String, description: String) {
        // Set the image, title, and description
        expandedImage.image = image
        titleLabel.text = title
        descriptionLabel.text = description
        
        storedImage = image
        storedTitle = title
        storedDescription = description

        changeConstraint()
        
        self.expandedImage.isHidden = false
        self.titleLabel.isHidden = false
        self.descriptionLabel.isHidden = false
        self.searchIcon.isHidden = false
        self.textView.isHidden = false
        self.debugButton.isHidden = false

        // Animate the expansion
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut,  animations: {
            // Show expanded UI elements
            self.changeVisability()
            self.superview?.layoutIfNeeded()
            self.setRadius()
        }) { _ in
            self.changeHiddenStatus()
            self.delegate?.viewExpanded()
            self.isExpanded = true
        }
    }
    
    func changeHiddenStatus() {
        self.expandedImage.isHidden = isExpanded
        self.titleLabel.isHidden = isExpanded
        self.descriptionLabel.isHidden = isExpanded
        
        // Hide original UI elements
        self.searchIcon.isHidden = !isExpanded
        self.textView.isHidden = !isExpanded
        self.debugButton.isHidden = !isExpanded
    }
    
    func changeVisability() {
        self.expandedImage.alpha = isExpanded ? 0.0 : 1.0
        self.titleLabel.alpha = isExpanded ? 0.0 : 1.0
        self.descriptionLabel.alpha = isExpanded ? 0.0 : 1.0
        
        self.searchIcon.alpha = !isExpanded ? 0.0 : 1.0
        self.textView.alpha = !isExpanded ? 0.0 : 1.0
        self.debugButton.alpha = !isExpanded ? 0.0 : 1.0
    }
    
    func changeConstraint() {
        guard let superview = superview else { return }
        NSLayoutConstraint.deactivate([
            originalBottomConstraint,
            originalHeightConstraint,
            originalTrailingConstraint,
            originalLeadingConstraint
        ])
        if isExpanded {
            originalBottomConstraint = self.bottomAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.bottomAnchor, constant: -10)
            originalHeightConstraint = self.heightAnchor.constraint(equalTo: superview.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15)
            originalTrailingConstraint.constant = -15
            originalLeadingConstraint.constant = 15
        } else {
            originalBottomConstraint = self.bottomAnchor.constraint(equalTo: superview.bottomAnchor)
            originalHeightConstraint = self.heightAnchor.constraint(equalTo: superview.heightAnchor, multiplier: 1)
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
        
        self.expandedImage.isHidden = false
        self.titleLabel.isHidden = false
        self.descriptionLabel.isHidden = false
        self.searchIcon.isHidden = false
        self.textView.isHidden = false
        self.debugButton.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations:{
            self.changeVisability()
            self.superview?.layoutIfNeeded()
            self.setRadius()
        }) { _ in
            self.changeHiddenStatus()
            self.delegate?.viewCollapsed()
            self.isExpanded = false
        }
    }
}
