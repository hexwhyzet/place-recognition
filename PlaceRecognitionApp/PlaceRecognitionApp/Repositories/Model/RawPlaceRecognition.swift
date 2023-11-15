//
//  RawPlaceRecognition.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 24.03.2023.
//

import Foundation

struct RawPlaceRecognition {
    let id : Int64
    let name : String
    let imageUrl : String
    let description : String
    let address: String
    let metro: [MetroStation]
    
    struct MetroStation {
        let id: Int
        let line_id: Int
        let name: Name
        let line: Line
    }
    
    struct Name: Codable {
        let RU: String
        let languages: [String]
    }

    struct Line: Codable {
        let id: Int
        let name: Name
    }
}

