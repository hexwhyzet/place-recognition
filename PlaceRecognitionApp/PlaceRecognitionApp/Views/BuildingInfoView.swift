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
    
    @State var isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label.tint(isSelected ? .black : .gray)
    }
}

struct BuildingInfoContentView: View {
    @State var data: PlaceRecognition
    
    @State var isFavouriteButtonSelected: Bool
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                Image(uiImage: data.image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(-10)
                    .frame(width: geometry.size.width)
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
                VStack {
                    VStack{
                        Capsule()
                            .fill(Color.secondary)
                            .frame(width: 50, height: 5)
                            .padding(.top, 13)
                            .opacity(0.3)
                        HStack{
                            Text(data.name)
                                .font(.SF.base(size: 35))
                                .fontWeight(.medium)
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
                                    let favouriteCharacters = UserDefaults.standard.array(forKey: "Favourite places") as? [Int64]
                                    let newFavouriteCharacters = favouriteCharacters?.filter {$0 != data.id}
                                    UserDefaults.standard.set(newFavouriteCharacters, forKey: "Favourite places")
                                }
                            }, label: {
                                Image("fav")
                                    .renderingMode(.template)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 19)
                                    .tint(isFavouriteButtonSelected ? Color.c_main : Color.c_secondary)
                            }).padding(.trailing, 10)
                        }.padding(.top, 25)
                        HStack{
                            Image("address")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 19)
                                .tint(Color(UIColor.main))
                            Text(data.address)
                                .font(.SF.base(size: 16))
                                .foregroundColor(Color(uiColor: .main))
                                .padding(.trailing, 30)
                                .fontWeight(.light)
                            Image("Moscow_Metro")
                                .renderingMode(.template)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 15.5)
                                .tint(Color(UIColor.main))
                            Text(data.metro)
                                .font(.SF.base(size: 16))
                                .foregroundColor(Color(uiColor: .main))
                                .fontWeight(.light)
                            Spacer()
                        }.opacity(0.3)
                            .font(.subheadline)
                        ScrollView {
                            Text(data.description)
                                .font(.SF.base(size: 20))
                                .fontWeight(.light)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(Color(uiColor: .main))
                        }
                    }.padding(.horizontal, 27.5)

                }.background(Color(uiColor: .bg))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top, -40)
            }
        }
    }
    
}

struct BuildingInfoContentView_Previews: PreviewProvider {
    static var previews: some View {
        BuildingInfoContentView(
            data: PlaceRecognition(id: 1, name: "Дом Морозова", description: "Особняк, построенный в 1895-1899 годах архитектором Виктором Мазыриным по заказу миллионера Арсения Абрамовича Морозова.\nЗдание, сочетающее элементы модерна и эклектики, представляет собой уникальный для московской архитектуры образец яркой и экзотической стилизации в неомавританском духе. Особняк, построенный в 1895-1899 годах архитектором Виктором Мазыриным по заказу миллионера Арсения Абрамовича Морозова.\nЗдание, сочетающее элементы модерна и эклектики, представляет собой уникальный для московской архитектуры образец яркой и экзотической стилизации в неомавританском духе. Особняк, построенный в 1895-1899 годах архитектором Виктором Мазыриным по заказу миллионера Арсения Абрамовича Морозова.\nЗдание, сочетающее элементы модерна и эклектики, представляет собой уникальный для московской архитектуры образец яркой и экзотической стилизации в неомавританском духе. Особняк, построенный в 1895-1899 годах архитектором Виктором Мазыриным по заказу миллионера Арсения Абрамовича Морозова.\nЗдание, сочетающее элементы модерна и эклектики, представляет собой уникальный для московской архитектуры образец яркой и экзотической стилизации в неомавританском духе. ", image: UIImage(named: "sample_building")!, address: "ул. Воздвиженка, 16", metro: "Арбатская"), isFavouriteButtonSelected: false
        )
    }
}

class BuildingInfoView: UIView {
    
    private var hostingView: HostingView<BuildingInfoContentView>!
    
    private var swiftUIView: BuildingInfoContentView = BuildingInfoContentView(data: PlaceRecognition(id: 1, name: "Дом Морозова", description: "Особняк, построенный в 1895-1899 годах архитектором Виктором Мазыриным по заказу миллионера Арсения Абрамовича Морозова.\nЗдание, сочетающее элементы модерна и эклектики, представляет собой уникальный для московской архитектуры образец яркой и экзотической стилизации в неомавританском духе.", image: UIImage(named: "sample_building")!, address: "ул. Воздвиженка, 16", metro: "Арбатская"), isFavouriteButtonSelected: false
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
        swiftUIView = BuildingInfoContentView(data: place, isFavouriteButtonSelected: is_fav)
        hostingView.removeFromSuperview()
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


