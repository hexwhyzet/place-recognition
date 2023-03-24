//
//  PlaceRecognizerDelegate.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 23.03.2023.
//

import Foundation
import UIKit

protocol PlaceRecognizerDelegate {
    func showPlaceRecognition(recognition: PlaceRecognition) -> Task<Void, Error>
    func getSnapshot() -> UIImage
}

protocol PlaceRecognizerCompleteDelegate {
    func recognitionCompleted()
}
