import Foundation
import UIKit
import SwiftUI

extension UIColor {
    static let main = UIColor(named: "Main")!
    static let bg = UIColor(named: "BG")!
    static let secondary = UIColor(named: "Secondary")!
    
    func interpolate(to color: UIColor, progress: CGFloat) -> UIColor {
            let progress = min(max(progress, 0), 1)

            var r1: CGFloat = 0, g1: CGFloat = 0, b1: CGFloat = 0, a1: CGFloat = 0
            var r2: CGFloat = 0, g2: CGFloat = 0, b2: CGFloat = 0, a2: CGFloat = 0

            getRed(&r1, green: &g1, blue: &b1, alpha: &a1)
            color.getRed(&r2, green: &g2, blue: &b2, alpha: &a2)

            let r = r1 + (r2 - r1) * progress
            let g = g1 + (g2 - g1) * progress
            let b = b1 + (b2 - b1) * progress
            let a = a1 + (a2 - a1) * progress

            return UIColor(red: r, green: g, blue: b, alpha: a)
        }
}

extension Color {
    static let c_main = Color(uiColor: .main)
    static let c_bg = Color(uiColor: .bg)
    static let c_secondary = Color(uiColor: .secondary)
}
