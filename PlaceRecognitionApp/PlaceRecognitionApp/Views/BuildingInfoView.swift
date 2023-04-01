//
//  BuildingInfoView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 01.04.2023.
//

import Foundation
import UIKit
import SwiftUI

struct BuildingInfoContentView: View {
    var photo: Image
    var title: String
    var address: String
    var metroStation: String
    var description: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            photo
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
            
            HStack {
                Text(address)
                Spacer()
                Text(metroStation)
            }
            .font(.subheadline)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
    }
}

class MyCustomUIView: UIView {
    
    private var hostingView: HostingView<BuildingInfoContentView>!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingView()
    }
    
    private func setupHostingView() {
        // Replace with your own SwiftUI view.
        let swiftUIView = BuildingInfoContentView(
            photo: Image("sample_photo"),
            title: "Example Place",
            address: "123 Main St",
            metroStation: "Central Station",
            description: "This is a description of the example place, showcasing its features and interesting aspects."
        )
        
        hostingView = HostingView(rootView: swiftUIView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: self.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}


