// Widget extension 的進入點。
// macOS 14+ 用 @main 標記 WidgetBundle，不再需要在 Info.plist 寫 NSExtensionPrincipalClass。
import WidgetKit
import SwiftUI

@main
struct BimonthWidgetBundle: WidgetBundle {
    var body: some Widget {
        BimonthWidget()
    }
}
