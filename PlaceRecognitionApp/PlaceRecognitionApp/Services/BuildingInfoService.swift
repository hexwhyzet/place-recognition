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
    
    func getBuildingInfoBy(descriptors: [Descriptor]) async throws -> PlaceRecognition {
        let rawData = _buildingRepository.getInfoByDecriptor(descriptor: descriptors.first!)
        return try await withCheckedThrowingContinuation { continuation in
            getInfoTask = Task {
                do {
                    guard let url = URL(string: rawData.imageUrl) else {
                        throw NSError(domain: "InvalidUrlData", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to form URL"])
                    }
                    let image = try await downloadImage(from: url)
                    // TODO: Change id name 
                    let placeRecognition = PlaceRecognition(id: String(rawData.name), description: rawData.description + descriptors.first!.information , image: image, multiArray: nil)
                    continuation.resume(returning: placeRecognition)
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
