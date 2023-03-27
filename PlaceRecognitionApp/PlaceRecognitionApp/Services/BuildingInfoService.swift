//
//  BuildingInfoService.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 23.03.2023.
//

import Foundation
import UIKit
import CoreML

class BuildingInfoService {
    
    let _buildingRepository: IBuildingInfoRepository = BuildingInfoRepository()
    
    private var getInfoTask: Task<Void, Error>?
    
    private func mlMultiArrayToFloatArray(_ descriptor: Descriptor) -> [Float] {
        let mlArray = descriptor.descriptor
        let count = mlArray.count
        let dataPointer = mlArray.dataPointer.bindMemory(to: Float.self, capacity: count)
        let floatArray = Array(UnsafeBufferPointer(start: dataPointer, count: count))
        print(floatArray.count)
        return floatArray
    }
    
    func cancelTask() {
        print("Cancel service")
        getInfoTask?.cancel()
        getInfoTask = nil
    }
    
    func getBuildingInfoBy(descriptors: [Descriptor]) async throws -> PlaceRecognition {
        print("Start getting place Recognition from service")
        let rawData = try await _buildingRepository.getInfoByDecriptor(descriptor: mlMultiArrayToFloatArray(descriptors.first!))
        print("Got raw data from repository")
        return try await withCheckedThrowingContinuation { continuation in
            getInfoTask = Task {
                do {
                    guard let url = URL(string: rawData.imageUrl) else {
                        throw NSError(domain: "InvalidUrlData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to form URL"])
                    }
                    let image = try await downloadImage(from: url)
                    let placeRecognition = PlaceRecognition(name: String(rawData.name), description: rawData.description, image: image, multiArray: nil)
                    continuation.resume(returning: placeRecognition)
                    print("Got place recognition from service")
                } catch let error {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func downloadImage(from url: URL) async throws -> UIImage {
        return try await withCheckedThrowingContinuation { continuation in
            URLSession.shared.dataTask(with: url) { data, response, error in
                if let data = data, let image = UIImage(data: data) {
                    continuation.resume(returning: image)
                } else {
                    continuation.resume(throwing: error ?? NSError(domain: "ImageDownloadError", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to download image"]))
                }
            }.resume()
        }
    }
}
