import SwiftUI

struct TasksView: View {
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Image(systemName: "checklist")
                    .font(.system(size: 48))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                
                Text("Tasks")
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
        .navigationTitle("Tasks")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationStack {
        TasksView()
    }
}
