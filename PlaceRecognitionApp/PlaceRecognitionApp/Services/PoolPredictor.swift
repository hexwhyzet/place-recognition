//
//  ImagePredictor.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 18.02.2023.
//

import Vision
import UIKit
import CoreImage

class PoolPredictor {
    
    static func createPool() -> Pool{
        let defaultConfig = MLModelConfiguration()
        return try! Pool(configuration: defaultConfig)
    }
    
    let model = createPool()
    
    enum PoolError: Error {
        case NoReceivedDescriptor
    }
    
    func predict(array: MLMultiArray) throws -> Descriptor {
        let input = PoolInput(x: array)
        guard let output = try? model.prediction(input: input) else {
            throw PoolError.NoReceivedDescriptor
        }
        return Descriptor(descriptor: output.var_5964, information: output.var_5964.description)
    }
}


class NetVladPredictor {
    
    static func createNetVlad() -> NetVlad{
        let defaultConfig = MLModelConfiguration()
        return try! NetVlad(configuration: defaultConfig)
    }
    
    let model = createNetVlad()
    
    enum NetVladError: Error {
        case NoReceivedDescriptor
    }
    
    typealias ImagePredictionHandler = (_ predictions: Descriptor?) -> Void
    
    func predict(image: UIImage, completionHandler: @escaping ImagePredictionHandler) throws {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        
        guard let photoImage = image.cgImage else {
            fatalError("Photo doesn't have underlying CGImage.")
        }
        let imageClassificationRequest = VNCoreMLRequest(model: try VNCoreMLModel(for: model.model) ) { (request, error) in
            
            let predictionHandler = completionHandler
            
            var predictions: [Descriptor]? = nil
            
            defer {
                predictionHandler(predictions?.first)
            }
            
            if let error = error {
                print("Vision image classification error...\n\n\(error.localizedDescription)")
                return
            }
            
            if request.results == nil {
                print("Vision request had no results.")
                return
            }
            
            guard let observations = request.results as? [VNCoreMLFeatureValueObservation] else {
                print("VNRequest produced the wrong result type: \(type(of: request.results)).")
                return
            }
            
            predictions = observations.compactMap { observation in
                guard let multiArray = observation.featureValue.multiArrayValue else {
                    return nil
                }
                return Descriptor(descriptor: multiArray, information: observation.description)
            }
        }
        imageClassificationRequest.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: photoImage, orientation: orientation)
        let requests: [VNRequest] = [imageClassificationRequest]
        
        try handler.perform(requests)
    }
}

