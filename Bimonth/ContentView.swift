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

            Text("Add the Bimonth widget from Notification Center, or right-click the desktop and choose Edit Widgets.")
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
