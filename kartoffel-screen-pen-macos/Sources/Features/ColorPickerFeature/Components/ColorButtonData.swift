import Foundation
import CoreGraphics

struct ColorButtonData: Equatable, Identifiable {
    
    let id: Int
    let color: CGColor
    var isSelected: Bool
    
    init(
        id: Int,
        color: CGColor,
        isSelected: Bool = false
    ) {
        self.id = id
        self.color = color
        self.isSelected = isSelected
    }
}
