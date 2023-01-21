//
//  LocalPlaceRecognizer.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import ARKit

class LocalPlaceRecognizer: PlaceRecognizer {
    func recognize(image: CVPixelBuffer) async throws -> PlaceRecognition {
        return PlaceRecognition(id: "1", description: "2", image: UIImage(named: "Radar")!)
    }
}
