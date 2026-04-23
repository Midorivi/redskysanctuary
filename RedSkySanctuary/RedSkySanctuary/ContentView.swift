import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Image(systemName: "sun.max.fill")
                    .font(.system(size: 42))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.orange)

                Text("Red Sky Sanctuary")
                    .font(.system(.title, design: .rounded).bold())
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
            .background(Color(.systemBackground))
            .navigationTitle("Welcome")
        }
    }
}

#Preview {
    ContentView()
}
