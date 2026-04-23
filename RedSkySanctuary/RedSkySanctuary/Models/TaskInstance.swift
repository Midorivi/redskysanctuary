import SwiftData
import Foundation

@Model
final class TaskInstance {
    var id: UUID = UUID()
    var date: Date = .now
    var isAdHoc: Bool = false
    
    var template: TaskTemplate?
    
    @Relationship(deleteRule: .cascade, inverse: \TaskInstanceItem.instance)
    var items: [TaskInstanceItem]? = []
    
    init(
        date: Date = .now,
        isAdHoc: Bool = false
    ) {
        self.date = date
        self.isAdHoc = isAdHoc
    }
    
    var displayDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}
