import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Dashboard", systemImage: "house.fill") {
                NavigationStack {
                    DashboardView()
                }
            }
            
            Tab("Animals", systemImage: "pawprint.fill") {
                NavigationStack {
                    AnimalsListView()
                }
            }
            
            Tab("Tasks", systemImage: "checklist") {
                NavigationStack {
                    TasksView()
                }
            }
            
            Tab("Supplies", systemImage: "shippingbox.fill") {
                NavigationStack {
                    SuppliesView()
                }
            }
            
            Tab("More", systemImage: "ellipsis.circle.fill") {
                NavigationStack {
                    MoreView()
                }
            }
        }
        .tint(.blue)
        .toolbarBackground(.ultraThinMaterial, for: .tabBar)
    }
}

#Preview {
    ContentView()
}
