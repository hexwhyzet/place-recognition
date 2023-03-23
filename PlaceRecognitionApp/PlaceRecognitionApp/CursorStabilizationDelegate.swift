//
//  CursorStabilizationDelegate.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 23.03.2023.
//

import Foundation

protocol CursorStabilizationDelegate: AnyObject {
    func cursorStabilized()
    func cursorUnstabilized()
}
