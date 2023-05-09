//
//  MixVPRPrecitor.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 09.05.2023.
//

import Vision
import UIKit
import CoreImage

class ResnetPredictor {
    
    static func createResnet() -> Resnet{
        let defaultConfig = MLModelConfiguration()
        return try! Resnet(configuration: defaultConfig)
    }
    
    let model = createResnet()
    
    enum MixVPRError: Error {
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

class MixVPREndPredictor {
    
    static func createEnd() -> MixVPREnd{
        let defaultConfig = MLModelConfiguration()
        return try! MixVPREnd(configuration: defaultConfig)
    }
    
    let model = createEnd()
    
    enum PoolError: Error {
        case NoReceivedDescriptor
    }
    
    func predict(array: MLMultiArray) throws -> Descriptor {
        let input = MixVPREndInput(x_1: array)
        guard let output = try? model.prediction(input: input) else {
            throw PoolError.NoReceivedDescriptor
        }
        return Descriptor(descriptor: output.var_107, information: output.var_107.description)
    }
}

