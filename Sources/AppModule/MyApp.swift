import PlaygroundTester
import SwiftUI

@main
struct MyApp {
    init() {
        PlaygroundTester.PlaygroundTesterConfiguration.isTesting = true
    }
}

extension MyApp: App {
    var body: some Scene {
        WindowGroup {
            PlaygroundTester.PlaygroundTesterWrapperView {
                ContentView()
            }
        }
    }
}
