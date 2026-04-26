// Host app exists only to register the widget extension and explain how to
// install it; the window stays tightly sized to ContentView so macOS doesn't
// remember and reopen it at an arbitrary saved width.
import SwiftUI

@main
struct BimonthApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .windowResizability(.contentSize)
    }
}
