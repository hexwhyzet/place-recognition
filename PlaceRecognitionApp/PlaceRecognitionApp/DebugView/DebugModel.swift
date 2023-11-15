//
//  DebugModel.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 15.11.2023.
//

import Foundation


@MainActor
class DebugModel: ObservableObject {
    
    // MARK: - User Details
    
    @Published var debugUrl: String = UserDefaults.standard.string(forKey: "debugURL") ?? "http://51.250.107.202:8000/recognize"
    
    @Published var debugToken: String = UserDefaults.standard.string(forKey: "debugToken") ?? "aboba"

    
    
    // Save all fields
    public func saveInUserDefault() {
        print("Save to user default")
        UserDefaults.standard.set(debugUrl, forKey: "debugURL")
        UserDefaults.standard.set(debugToken, forKey: "debugToken")

    }
    
}
