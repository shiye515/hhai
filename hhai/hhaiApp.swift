import SwiftUI
import SwiftData

@main
struct hhaiApp: App {
    let persistence = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(persistence.container)
    }
}
