//
//  LocalPlaceRecognizer.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import ARKit

class LocalPlaceRecognizer: PlaceRecognizer {
    
    let imagePredictor = ImagePredictor()
    
    enum RecognizerError: Error {
        case NoReceivedDescriptor
    }
    
    func recognize(image: UIImage) async throws -> PlaceRecognition {
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try imagePredictor.makePredictions(for: image) { descriptor in
                    guard let descriptor = descriptor else {
                        continuation.resume(throwing: RecognizerError.NoReceivedDescriptor)
                        return
                    }
                    if descriptor.isEmpty {
                        continuation.resume(throwing: RecognizerError.NoReceivedDescriptor)
                    } else {
                        let placeRecognition = PlaceRecognition(id: "1", description: descriptor.first!.information, image: UIImage(named: "Radar")!, multiArray: descriptor.first!.descriptor)
                        continuation.resume(returning: placeRecognition)
                    }
                }
            } catch let error {
                continuation.resume(throwing: error)
            }
            
            
        }
    }
        
}

extension LocalPlaceRecognizer: CursorStabilizationDelegate {
    func cursorStabilized() {
        return
    }
    
    func cursorUnstabilized() {
        return
    }
}
