//
//  IBuildingInfoRepository.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 24.03.2023.
//

import Foundation

protocol IBuildingInfoRepository {
    func getInfoByDecriptor(descriptor: [Float]) async throws -> RawPlaceRecognition
}
