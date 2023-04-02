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
    @State var data: PlaceRecognition
    
    @State var isFavouriteButtonSelected: Bool
    
    var body: some View {
        VStack {
            Image(uiImage: data.image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(-10)
            VStack(alignment: .center) {
                VStack {
                    Capsule()
                        .fill(Color.secondary)
                        .frame(width: 50, height: 5)
                        .padding(15)
                    HStack{
                        Text(data.name)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color(uiColor: .main))
                        Spacer()
                        Button(action: {
                            isFavouriteButtonSelected.toggle()
                            if isFavouriteButtonSelected {
                                let favouriteCharacters = UserDefaults.standard.array(forKey: "Favourite places") as? [Int64]
                                var newFavouriteCharacters = favouriteCharacters
                                newFavouriteCharacters?.append(data.id)
                                UserDefaults.standard.set(newFavouriteCharacters, forKey: "Favourite places")
                            } else {
                                let favouriteCharacters = UserDefaults.standard.array(forKey: "Favourite places") as? [Int]
                                let newFavouriteCharacters = favouriteCharacters?.filter {$0 != data.id}
                                UserDefaults.standard.set(newFavouriteCharacters, forKey: "Favourite places")
                            }
                        }, label: {
                            Image(isFavouriteButtonSelected ? "Favourite_button_s" : "Favourite_button_u")
                                .renderingMode(isFavouriteButtonSelected ? .template : .original)
                        })
                        .buttonStyle(FavouriteButton())
                        
                    }
                    
                }.padding(.horizontal, 20)
                
                HStack {
                    HStack{
                        Image("address")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 15)
                            .tint(Color(UIColor.main))
                        Text(data.address)
                            .foregroundColor(Color(uiColor: .main))
                        Spacer()
                        Image("Moscow_Metro")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 11)
                            .tint(Color(UIColor.main))
                        Text(data.metro)
                            .foregroundColor(Color(uiColor: .main))
                        Spacer()
                    }.opacity(0.5)
                        .padding(.horizontal, 20)
                }
                .font(.subheadline)
                
                Text(data.description)
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
                    .foregroundColor(Color(uiColor: .main))
            }
        }.background(Color(uiColor: .bg))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .padding(.top, -40)
    }
    
}

struct BuildingInfoContentView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingInfoContentView(
            data: PlaceRecognition(id: 1, name: "Example Place", description: "This is a description of the example place, showcasing its features and interesting aspects.", image: UIImage(named: "sample_building")!, address: "123 Main St", metro: "Central Station"), isFavouriteButtonSelected: false
        )
    }
}

class BuildingInfoView: UIView {
    
    private var hostingView: HostingView<BuildingInfoContentView>!
    
    private var swiftUIView: BuildingInfoContentView = BuildingInfoContentView(data: PlaceRecognition(id: 1, name: "Example Place", description: "This is a description of the example place, showcasing its features and interesting aspects.", image: UIImage(named: "sample_building")!, address: "123 Main St", metro: "Central Station"), isFavouriteButtonSelected: false
    )
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupHostingView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupHostingView()
    }
    
    func updateHostingView(place: PlaceRecognition, is_fav: Bool) {
        // Replace with your own SwiftUI view.
        swiftUIView = BuildingInfoContentView(data: place, isFavouriteButtonSelected: is_fav
        )
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


