//
//  LocalPlaceRecognizer.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 14.01.2023.
//

import Foundation
import ARKit

class LocalPlaceRecognizer: PlaceRecognizer {
    
    var recognitionTask: Task<PlaceRecognition?, Error>?
    
    var showTask: Task<Void, Error>?
    
    let imagePredictor = ImagePredictor()
    
    let poolPredictor = PoolPredictor()
    
    var delegate: PlaceRecognizerDelegate? = nil
    
    var completeDelegate: PlaceRecognizerCompleteDelegate? = nil
    
    let buildingInfoService: BuildingInfoService = BuildingInfoService()
    
    enum RecognizerError: Error {
        case NoReceivedDescriptor
    }
    
    func recognize(image: UIImage) async throws -> PlaceRecognition {
        return try await withCheckedThrowingContinuation { continuation in
            Task {
                do {
                    try imagePredictor.makePredictions(for: image) { descriptor in
                        Task {
                            guard let descriptor = descriptor else {
                                throw RecognizerError.NoReceivedDescriptor
                            }
                            if descriptor.isEmpty {
                                throw RecognizerError.NoReceivedDescriptor
                            } else {
                                // TODO: Debug only
                                print(descriptor.description)
                                let pool = try self.poolPredictor.predict(array: descriptor.first!.descriptor)
                                let placeRecognition = try await self.buildingInfoService.getBuildingInfoBy(descriptors: pool)
                                self.completeDelegate?.recognitionCompleted()
                                continuation.resume(returning: placeRecognition)
                            }
                        }
                    }
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }

    
}


extension LocalPlaceRecognizer: CursorStabilizationDelegate {
    func cursorCompleted() {
        Task {
            guard let recognitionTask = recognitionTask else {
                        print("Recognition task is not available")
                        return
                    }
            do {
                guard let placeRecognition = try await recognitionTask.value else {
                    print("Recognition is not ready")
                    return
                }
                self.showTask = self.delegate?.showPlaceRecognition(recognition: placeRecognition)
            } catch {
                print("An error occurred while waiting for recognitionTask: \(error)")
            }
        }
        
    }
    
    func cursorStabilized() {
        recognitionTask = Task {
            print("Stable")
            do {
                let placeRecognition = try await self.recognize(image: (self.delegate?.getSnapshot())!)
                return placeRecognition
            } catch is CancellationError {
                // Handle cancellation gracefully
                print("The task was cancelled")
            } catch {
                // Handle other errors
                print("An error occurred: \(error)")
            }
            return nil
        }
    }
    
    func cursorUnstabilized() {
        print("Unstable")
        recognitionTask?.cancel()
        showTask?.cancel()
        buildingInfoService.cancelTask()
        showTask = nil
        recognitionTask = nil
        return
    }
}
