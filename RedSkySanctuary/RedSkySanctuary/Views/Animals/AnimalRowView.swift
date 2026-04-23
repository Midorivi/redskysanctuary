import SwiftUI
import SwiftData

struct AnimalRowView: View {
    let animal: Animal

    private var primaryPhoto: AnimalPhoto? {
        animal.photos?.first(where: { $0.isPrimary }) ?? animal.photos?.first
    }

    var body: some View {
        HStack(spacing: 12) {
            if let thumbnailData = primaryPhoto?.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 50, height: 50)
                    .clipShape(Circle())
            } else {
                Image(systemName: "pawprint.fill")
                    .font(.title2)
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                    .frame(width: 50, height: 50)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(animal.displayName)
                    .font(.headline)
                    .foregroundStyle(.primary)

                HStack(spacing: 4) {
                    Text(animal.animalType.capitalized)
                    if let breed = animal.breed, !breed.isEmpty {
                        Text("·")
                        Text(breed)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)

                if let age = animal.age {
                    Text(age == 1 ? "1 year old" : "\(age) years old")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)

    let animal = Animal(
        name: "Maple",
        animalType: "horse",
        breed: "Quarter Horse",
        birthday: Calendar.current.date(byAdding: .year, value: -5, to: .now)
    )
    container.mainContext.insert(animal)

    return NavigationStack {
        List {
            AnimalRowView(animal: animal)
        }
    }
    .modelContainer(container)
}
