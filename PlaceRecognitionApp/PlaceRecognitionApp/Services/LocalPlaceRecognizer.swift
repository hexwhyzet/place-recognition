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
    
    var delegate: PlaceRecognizerDelegate? = nil
    
    var completeDelegate: PlaceRecognizerCompleteDelegate? = nil
    
    let buildingInfoService: BuildingInfoService = BuildingInfoService()
    
    enum RecognizerError: Error {
        case NoReceivedDescriptor
    }
    
    func recognize(image: UIImage) async throws -> PlaceRecognition {
        // TODO: Make for debug
        try await Task.sleep(nanoseconds: 5000000000)
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
                        let placeRecognition = self.buildingInfoService.getBuildingInfoBy(descriptor: descriptor)
                        self.completeDelegate?.recognitionCompleted()
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
        Task {
            print("Stable")
            // TODO: debug
            let placeRecognition = try! await self.recognize(image: (self.delegate?.getSnapshot())!)
            self.delegate?.showPlaceRecognition(recognition: placeRecognition)
        }
    }
    
    func cursorUnstabilized() {
        print("Unstable")
        return
    }
}
