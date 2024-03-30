import Foundation

struct 💾Log: Codable {
    let leftID: UUID
    let rightID: UUID
    let lineLength: Float
    let rotationRadians: Double
    let date: Date
}

extension 💾Log: Identifiable, Hashable {
    var id: UUID { self.leftID }
}
