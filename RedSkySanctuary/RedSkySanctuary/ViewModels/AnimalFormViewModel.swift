import SwiftUI
import SwiftData

@MainActor @Observable
final class AnimalFormViewModel {
    var name: String = ""
    var animalType: String = ""
    var customAnimalType: String = ""
    var breed: String = ""
    var birthday: Date = .now
    var hasBirthday: Bool = false
    var feedingInstructions: String = ""
    var notes: String = ""
    var status: String = AnimalStatus.active
    var selectedPhotos: [(fullData: Data, thumbnailData: Data)] = []
    var primaryPhotoIndex: Int? = nil

    private(set) var isEditMode: Bool = false
    private var editingAnimal: Animal?

    // MARK: - Preset Animal Types

    static let presetTypes = [
        AnimalType.horse,
        AnimalType.goat,
        AnimalType.pig,
        AnimalType.chicken,
        AnimalType.duck
    ]

    // MARK: - Validation

    var resolvedAnimalType: String {
        animalType == "other" ? customAnimalType.trimmingCharacters(in: .whitespaces) : animalType
    }

    var canSave: Bool {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let type = resolvedAnimalType
        return !trimmedName.isEmpty && !type.isEmpty
    }

    // MARK: - Init

    init(animal: Animal? = nil) {
        guard let animal else { return }

        isEditMode = true
        editingAnimal = animal
        name = animal.name
        animalType = Self.presetTypes.contains(animal.animalType) ? animal.animalType : "other"
        if animalType == "other" {
            customAnimalType = animal.animalType
        }
        breed = animal.breed ?? ""
        if let bday = animal.birthday {
            birthday = bday
            hasBirthday = true
        }
        feedingInstructions = animal.feedingInstructions ?? ""
        notes = animal.notes ?? ""
        status = animal.status

        if let photos = animal.photos {
            for (index, photo) in photos.enumerated() {
                if let full = photo.imageData, let thumb = photo.thumbnailData {
                    selectedPhotos.append((fullData: full, thumbnailData: thumb))
                    if photo.isPrimary {
                        primaryPhotoIndex = index
                    }
                }
            }
        }
    }

    // MARK: - Save

    func save(in context: ModelContext) {
        let animal = editingAnimal ?? Animal()

        animal.name = name.trimmingCharacters(in: .whitespaces)
        animal.animalType = resolvedAnimalType
        animal.breed = breed.isEmpty ? nil : breed.trimmingCharacters(in: .whitespaces)
        animal.birthday = hasBirthday ? birthday : nil
        animal.feedingInstructions = feedingInstructions.isEmpty ? nil : feedingInstructions
        animal.notes = notes.isEmpty ? nil : notes
        animal.status = status

        if !isEditMode {
            context.insert(animal)
        }

        if isEditMode, let existingPhotos = animal.photos {
            for photo in existingPhotos {
                context.delete(photo)
            }
        }

        for (index, photoData) in selectedPhotos.enumerated() {
            let photo = AnimalPhoto(
                imageData: photoData.fullData,
                thumbnailData: photoData.thumbnailData,
                isPrimary: index == (primaryPhotoIndex ?? 0) && !selectedPhotos.isEmpty,
                animal: animal
            )
            context.insert(photo)
        }
    }

    // MARK: - Thumbnail Generation

    func generateThumbnail(from imageData: Data, maxDimension: CGFloat = 300) -> Data? {
        guard let image = UIImage(data: imageData) else { return nil }

        let scale: CGFloat
        if image.size.width > image.size.height {
            scale = maxDimension / image.size.width
        } else {
            scale = maxDimension / image.size.height
        }

        let newSize = CGSize(
            width: image.size.width * scale,
            height: image.size.height * scale
        )

        let renderer = UIGraphicsImageRenderer(size: newSize)
        let thumbnailImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }

        return thumbnailImage.jpegData(compressionQuality: 0.7)
    }
}
