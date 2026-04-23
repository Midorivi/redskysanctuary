import SwiftUI
import SwiftData
import PhotosUI

struct AnimalFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel: AnimalFormViewModel
    @State private var showPhotoPicker = false
    @State private var pickerImageData: Data?
    @State private var pickerThumbnailData: Data?
    @State private var saveCount = 0

    init(animal: Animal? = nil) {
        _viewModel = State(initialValue: AnimalFormViewModel(animal: animal))
    }

    var body: some View {
        Form {
            basicInfoSection
            detailsSection
            photosSection

            if viewModel.isEditMode {
                statusSection
            }
        }
        .navigationTitle(viewModel.isEditMode ? "Edit Animal" : "Add Animal")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel") {
                    dismiss()
                }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    viewModel.save(in: modelContext)
                    saveCount += 1
                    dismiss()
                }
                .disabled(!viewModel.canSave)
                .fontWeight(.semibold)
            }
        }
        .sensoryFeedback(.success, trigger: saveCount)
    }

    // MARK: - Basic Info

    private var basicInfoSection: some View {
        Section {
            FormField(
                label: "Name",
                placeholder: "Animal name",
                text: $viewModel.name
            )

            VStack(alignment: .leading, spacing: 6) {
                Text("Type")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Picker("Type", selection: $viewModel.animalType) {
                    Text("Select type").tag("")
                    ForEach(AnimalFormViewModel.presetTypes, id: \.self) { type in
                        Text(type.capitalized).tag(type)
                    }
                    Text("Other").tag("other")
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }

            if viewModel.animalType == "other" {
                FormField(
                    label: "Custom Type",
                    placeholder: "e.g. Llama, Alpaca",
                    text: $viewModel.customAnimalType
                )
            }

            FormField(
                label: "Breed",
                placeholder: "Breed (optional)",
                text: $viewModel.breed
            )
        } header: {
            Text("Basic Info")
        }
    }

    // MARK: - Details

    private var detailsSection: some View {
        Section {
            Toggle("Has Birthday", isOn: $viewModel.hasBirthday.animation(.spring(.snappy)))

            if viewModel.hasBirthday {
                DatePicker(
                    "Birthday",
                    selection: $viewModel.birthday,
                    in: ...Date.now,
                    displayedComponents: .date
                )
            }

            FormField(
                label: "Feeding Instructions",
                placeholder: "Describe feeding routine",
                text: $viewModel.feedingInstructions,
                isMultiline: true
            )

            FormField(
                label: "Notes",
                placeholder: "Additional notes",
                text: $viewModel.notes,
                isMultiline: true
            )
        } header: {
            Text("Details")
        }
    }

    // MARK: - Photos

    private var photosSection: some View {
        Section {
            if !viewModel.selectedPhotos.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(Array(viewModel.selectedPhotos.enumerated()), id: \.offset) { index, photo in
                            photoThumbnail(photo.thumbnailData, index: index)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }

            Button {
                showPhotoPicker = true
            } label: {
                Label("Add Photo", systemImage: "photo.badge.plus")
                    .symbolRenderingMode(.hierarchical)
            }
            .sheet(isPresented: $showPhotoPicker) {
                photoPickerSheet
            }
        } header: {
            Text("Photos")
        }
    }

    private func photoThumbnail(_ thumbnailData: Data, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            if let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .stroke(
                                index == (viewModel.primaryPhotoIndex ?? 0) ? Color.blue : .clear,
                                lineWidth: 2
                            )
                    )
                    .onTapGesture {
                        viewModel.primaryPhotoIndex = index
                    }
            }

            Button {
                withAnimation(.spring(.snappy)) {
                    viewModel.selectedPhotos.remove(at: index)
                    if viewModel.primaryPhotoIndex == index {
                        viewModel.primaryPhotoIndex = viewModel.selectedPhotos.isEmpty ? nil : 0
                    } else if let primary = viewModel.primaryPhotoIndex, primary > index {
                        viewModel.primaryPhotoIndex = primary - 1
                    }
                }
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption)
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(.white, .red)
            }
            .buttonStyle(.plain)
            .offset(x: 4, y: -4)
        }
    }

    private var photoPickerSheet: some View {
        NavigationStack {
            VStack {
                PhotoPickerView(
                    selectedImageData: $pickerImageData,
                    selectedThumbnailData: $pickerThumbnailData
                )
                .padding(16)

                Spacer()
            }
            .navigationTitle("Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        pickerImageData = nil
                        pickerThumbnailData = nil
                        showPhotoPicker = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let full = pickerImageData, let thumb = pickerThumbnailData {
                            viewModel.selectedPhotos.append((fullData: full, thumbnailData: thumb))
                            if viewModel.primaryPhotoIndex == nil {
                                viewModel.primaryPhotoIndex = 0
                            }
                        }
                        pickerImageData = nil
                        pickerThumbnailData = nil
                        showPhotoPicker = false
                    }
                    .disabled(pickerImageData == nil)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: - Status (Edit Only)

    private var statusSection: some View {
        Section {
            Picker("Status", selection: $viewModel.status) {
                Text("Active").tag(AnimalStatus.active)
                Text("Deceased").tag(AnimalStatus.deceased)
                Text("Adopted").tag(AnimalStatus.adopted)
                Text("Transferred").tag(AnimalStatus.transferred)
            }
        } header: {
            Text("Status")
        }
    }
}

#Preview("Add Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)

    NavigationStack {
        AnimalFormView()
    }
    .modelContainer(container)
}

#Preview("Edit Mode") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Animal.self, configurations: config)

    let animal = Animal(
        name: "Maple",
        animalType: "horse",
        breed: "Quarter Horse",
        birthday: Calendar.current.date(byAdding: .year, value: -5, to: .now),
        feedingInstructions: "2 flakes hay twice daily",
        notes: "Gentle rescue horse"
    )
    container.mainContext.insert(animal)

    return NavigationStack {
        AnimalFormView(animal: animal)
    }
    .modelContainer(container)
}
