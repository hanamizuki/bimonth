// Container app 的進入點。
// Widget extension 必須有一個包覆它的 host app，這個 app 本身幾乎不做事，
// 僅提供 widget 註冊到系統的容器。
import SwiftUI

@main
struct BimonthApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
