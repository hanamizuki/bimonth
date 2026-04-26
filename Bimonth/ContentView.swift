import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 16) {
            // Brand `bark` keeps the only visual element in the container app on-brand.
            // The container app exists only to host the widget extension; styling stays
            // restrained so the actual app icon (in Dock and Finder) carries the brand.
            Image(systemName: "calendar")
                .font(.system(size: 48))
                .foregroundStyle(Color.brandBark)

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
