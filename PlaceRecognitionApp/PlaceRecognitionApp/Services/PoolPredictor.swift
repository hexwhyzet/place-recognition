//
//  ImagePredictor.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 18.02.2023.
//

import Vision
import UIKit

class PoolPredictor {
    
    static func createPool() -> Pool{
        let defaultConfig = MLModelConfiguration()
        return try! Pool(configuration: defaultConfig)
    }
    
    let model = createPool()
    
    enum PoolError: Error {
        case NoReceivedDescriptor
    }
    
    func predict(array: MLMultiArray) throws -> [Descriptor] {
        let input = PoolInput(x: array)
        guard let output = try? model.prediction(input: input) else {
            throw PoolError.NoReceivedDescriptor
        }
        return [Descriptor(descriptor: output.var_5964, information: output.var_5964.description) ]
    }
}

