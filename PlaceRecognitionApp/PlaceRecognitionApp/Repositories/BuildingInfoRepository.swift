//
//  BuildingInfoRepository.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 23.03.2023.
//

import Foundation
import UIKit

class BuildingInfoRepository: IBuildingInfoRepository {
    func getInfoByDecriptor(descriptor: Descriptor) -> RawPlaceRecognition {
        return RawPlaceRecognition(id: 123, name: "Random image", imageUrl: "https://picsum.photos/100/300", description: "Random image description")
    }
    
    
}
