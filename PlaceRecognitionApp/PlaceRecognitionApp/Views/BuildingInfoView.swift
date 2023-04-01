//
//  BuildingInfoView.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 01.04.2023.
//

import Foundation
import UIKit
import SwiftUI

struct FavouriteButton: ButtonStyle {
        
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.tint(Color(UIColor.main))
    }
}

struct BuildingInfoContentView: View {
    @State var photo: Image
    @State var title: String
    @State var address: String
    @State var metroStation: String
    @State var description: String
    
    @State private var isFavouriteButtonSelected: Bool = false
    
    var body: some View {
        VStack() {
            photo
                .resizable()
                .aspectRatio(contentMode: .fit)
                .clipShape(Rectangle())
                .cornerRadius(10)
            HStack{
                Text(title)
                    .font(.title)
                    .fontWeight(.bold)
                    .foregroundColor(Color(uiColor: .main))
                Spacer()
                Button(action: {
                    isFavouriteButtonSelected.toggle()
                    title += "1"
                }, label: {
                    isFavouriteButtonSelected ? Image("Favourite_button_s").renderingMode(.template) : Image("Favourite_button_u")
                })
                .buttonStyle(FavouriteButton())
            }
            
            HStack {
                HStack{
                    Image("address")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 15)
                        .tint(Color(UIColor.main))
                    Text(address)
                        .foregroundColor(Color(uiColor: .main))
                    Spacer()
                    Image("Moscow_Metro")
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 11)
                        .tint(Color(UIColor.main))
                    Text(metroStation)
                        .foregroundColor(Color(uiColor: .main))
                    Spacer()
                }.opacity(0.5)
            }
            .font(.subheadline)
            
            Text(description)
                .font(.body)
                .multilineTextAlignment(.leading)
                .fixedSize(horizontal: false, vertical: true)
                .foregroundColor(Color(uiColor: .main))
        }
        .padding()
    }
}

struct BuildingInfoContentView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingInfoContentView(
            photo: Image("sample_building"),
            title: "Example Place",
            address: "123 Main St",
            metroStation: "Central Station",
            description: "This is a description of the example place, showcasing its features and interesting aspects."
        )
    }
}

class BuildingInfoView: UIView {
    
    private var hostingView: HostingView<BuildingInfoContentView>!
    
    private var swiftUIView: BuildingInfoContentView = BuildingInfoContentView(
        photo: Image("sample_building"),
        title: "Example Place",
        address: "123 Main St",
        metroStation: "Central Station",
        description: "This is a description of the example place, showcasing its features and interesting aspects."
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingView()
    }
    
    func updateHostingView(place: PlaceRecognition) {
        // Replace with your own SwiftUI view.
        swiftUIView.address = place.address
        swiftUIView.description = place.description
        swiftUIView.photo = Image(uiImage: place.image)
        swiftUIView.title = place.name
        swiftUIView.metroStation = place.metro
    }
    
    private func setupHostingView() {
        hostingView = HostingView(rootView: swiftUIView)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(hostingView)
        self.backgroundColor = .clear
        
        NSLayoutConstraint.activate([
            hostingView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            hostingView.topAnchor.constraint(equalTo: self.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
    }
}


