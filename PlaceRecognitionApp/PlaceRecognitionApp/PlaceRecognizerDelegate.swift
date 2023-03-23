//
//  PlaceRecognizerDelegate.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 23.03.2023.
//

import Foundation

protocol PlaceRecognizerDelegate {
    func showImage(image: UIImage)
    func showInformation(info: String)
}