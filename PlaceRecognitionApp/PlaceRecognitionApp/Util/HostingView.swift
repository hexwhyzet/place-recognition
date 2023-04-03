//
//  HostingView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 01.04.2023.
//

import Foundation
import UIKit
import SwiftUI

class HostingView<Content: View>: UIView {
    private var hostingController: UIHostingController<Content>!

    init(rootView: Content) {
        super.init(frame: .zero)
        self.hostingController = UIHostingController(rootView: rootView)
        setupHostingControllerView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupHostingControllerView() {
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingController.view)
        hostingController.view.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: self.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}
