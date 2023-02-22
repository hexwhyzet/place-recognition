//
//  SearchCapsuleView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 30.10.2022.
//

import Foundation
import UIKit

class SearchCapsuleView: UIView {
    
    var searchIcon = UIImageView()
    
    public var debugButton = UIButton(frame: CGRect(x: 0, y: 0, width: 40, height: 20))
    
    var textView: UITextView = UITextView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.translatesAutoresizingMaskIntoConstraints = false
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
        
        textView.backgroundColor = .secondary

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
    
    
    
    func setRadius() {
        let radius = self.frame.height / 2 - 1
        self.layer.cornerRadius = radius
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
