//
//  PlaceRecognizer.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import ARKit

struct PlaceRecognition {
    var id: String
    var description: String
    var image: UIImage
    var multiArray: MLMultiArray
}

protocol PlaceRecognizer {
    func recognize(image: UIImage) async throws -> PlaceRecognition
}
