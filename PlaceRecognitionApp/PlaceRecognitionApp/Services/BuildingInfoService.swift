//
//  BuildingInfoService.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 23.03.2023.
//

import Foundation
import UIKit

class BuildingInfoService {
    func getBuildingInfoBy(descriptor: [Descriptor]) -> PlaceRecognition {
        // TODO: need to write a connection with repository
        return PlaceRecognition(id: "1", description: descriptor.first!.information, image: UIImage(named: "Radar")!, multiArray: descriptor.first!.descriptor)
    }
}
