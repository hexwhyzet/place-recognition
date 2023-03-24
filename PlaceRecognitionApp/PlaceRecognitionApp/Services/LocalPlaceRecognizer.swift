//
//  LocalPlaceRecognizer.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import ARKit

class LocalPlaceRecognizer: PlaceRecognizer {
    
    var recognitionTask: Task<Void, Error>?
    
    var showTask: Task<Void, Error>?
    
    let imagePredictor = ImagePredictor()
    
    var delegate: PlaceRecognizerDelegate? = nil
    
    var completeDelegate: PlaceRecognizerCompleteDelegate? = nil
    
    let buildingInfoService: BuildingInfoService = BuildingInfoService()
    
    enum RecognizerError: Error {
        case NoReceivedDescriptor
    }
    
    func recognize(image: UIImage) async throws -> PlaceRecognition {
        
        return try await withCheckedThrowingContinuation { continuation in
            do {
                try imagePredictor.makePredictions(for: image) { descriptor in
                    Task {
                        guard let descriptor = descriptor else {
                            throw RecognizerError.NoReceivedDescriptor
                        }
                        if descriptor.isEmpty {
                            throw RecognizerError.NoReceivedDescriptor
                        } else {
                            let placeRecognition = try await self.buildingInfoService.getBuildingInfoBy(descriptors: descriptor)
                            // TODO: Debug use only
                            self.completeDelegate?.recognitionCompleted()
                            continuation.resume(returning: placeRecognition)
                        }
                    }
                }
            }
            catch let error {
                continuation.resume(throwing: error)
            }
        }
    }
    
}


extension LocalPlaceRecognizer: CursorStabilizationDelegate {
    func cursorStabilized() {
        recognitionTask = Task {
            print("Stable")
            // TODO: debug
            do {
                let placeRecognition = try await self.recognize(image: (self.delegate?.getSnapshot())!)
                self.showTask = self.delegate?.showPlaceRecognition(recognition: placeRecognition)
            } catch is CancellationError {
                // Handle cancellation gracefully
                print("The task was cancelled")
            } catch {
                // Handle other errors
                print("An error occurred: \(error)")
            }
        }
    }
    
    func cursorUnstabilized() {
        print("Unstable")
        recognitionTask?.cancel()
        showTask?.cancel()
        showTask = nil
        recognitionTask = nil
        return
    }
}
