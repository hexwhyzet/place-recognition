//
//  Fonts.swift
//  PlaceRecognitionApp
//
//  Created by ZhengWu Pan on 02.04.2023.
//

import Foundation
import SwiftUI

extension Font {
    struct SF {
        
        static func base(size: CGFloat) -> Font {
            .custom("SF Pro Display", size: size)
        }
    }
    
    struct SilkScreen {
        
        static func base(size: CGFloat) -> Font {
            .custom("Silkscreen", size: size)
        }
        
        static func bold(size: CGFloat) -> Font {
            .custom("Silkscreen-Bold", size: size)
        }
        
        static func regular(size: CGFloat) -> Font {
            .custom("Silkscreen-Regular", size: size)
        }
    }
}
