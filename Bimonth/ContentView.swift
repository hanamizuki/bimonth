// Container app 的主畫面。
// 此 app 的唯一目的是承載 widget extension，因此畫面上只簡單告知使用者
// 從 Notification Center 或桌面右鍵新增 widget。
import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(.orange)

            Text("Bimonth")
                .font(.title)
                .fontWeight(.semibold)

            Text("從通知中心或桌面右鍵點擊「Edit Widgets」新增雙月月曆 widget。")
                .font(.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
        }
        .frame(width: 380, height: 240)
    }
}

#Preview {
    ContentView()
}
