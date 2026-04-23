import SwiftUI

struct AnimalsListView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 48))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                
                Text("Animals")
                    .font(.system(.title3, design: .rounded).bold())
                    .foregroundStyle(.primary)
                
                Text("Coming Soon")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topCenter)
        .padding(16)
        .background(Color(.systemBackground))
        .navigationTitle("Animals")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        AnimalsListView()
    }
}
