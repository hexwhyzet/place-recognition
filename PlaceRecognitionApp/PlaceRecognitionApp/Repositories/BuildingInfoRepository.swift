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
        return RawPlaceRecognition(id: 123, name: "GuGong", imageUrl: "https://img.dpm.org.cn/Uploads/Picture/2021/02/09/s6022359a96808.jpg", description: "Gugong description")
    }
    
    
}
