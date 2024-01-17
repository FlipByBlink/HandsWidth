import SwiftUI

@main
struct HandsWidthApp: App {
    @StateObject private var model: 📱AppModel = .init()
    var body: some Scene {
        ImmersiveSpace(id: "measure") {
            ContentView()
                .environmentObject(self.model)
        }
        WindowGroup(id: "setting") {
            🛠️SettingView()
                .environmentObject(self.model)
        }
        .defaultSize(width: 400, height: 260)
    }
    init() {
        🧑HeadTrackingComponent.registerComponent()
        🧑HeadTrackingSystem.registerSystem()
    }
}
