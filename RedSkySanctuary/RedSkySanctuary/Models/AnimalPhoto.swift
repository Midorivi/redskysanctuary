import SwiftData
import Foundation

@Model
final class AnimalPhoto {
    var id: UUID = UUID()
    
    @Attribute(.externalStorage)
    var imageData: Data? = nil
    
    @Attribute(.externalStorage)
    var thumbnailData: Data? = nil
    
    var caption: String? = nil
    var dateAdded: Date = Date.now
    var isPrimary: Bool = false
    
    var animal: Animal?
    
    init(
        imageData: Data? = nil,
        thumbnailData: Data? = nil,
        caption: String? = nil,
        isPrimary: Bool = false,
        animal: Animal? = nil
    ) {
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.caption = caption
        self.isPrimary = isPrimary
        self.animal = animal
    }
}
