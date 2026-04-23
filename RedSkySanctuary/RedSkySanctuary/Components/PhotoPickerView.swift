import SwiftUI
import PhotosUI

struct PhotoPickerView: View {
    @Binding var selectedImageData: Data?
    @Binding var selectedThumbnailData: Data?
    @State private var selectedItem: PhotosPickerItem?

    var body: some View {
        VStack(spacing: 12) {
            if let selectedImageData,
               let uiImage = UIImage(data: selectedImageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 200)
                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                    .overlay(alignment: .topTrailing) {
                        Button {
                            withAnimation(.spring(.snappy)) {
                                self.selectedImageData = nil
                                self.selectedThumbnailData = nil
                                selectedItem = nil
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title2)
                                .symbolRenderingMode(.hierarchical)
                                .foregroundStyle(.white)
                        }
                        .buttonStyle(.scale)
                        .padding(8)
                    }
            } else {
                PhotosPicker(selection: $selectedItem, matching: .images) {
                    VStack(spacing: 8) {
                        Image(systemName: "photo.badge.plus")
                            .font(.largeTitle)
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.secondary)
                        Text("Add Photo")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 200)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 12, style: .continuous))
                }
                .buttonStyle(.scale)
            }
        }
        .onChange(of: selectedItem) { _, newItem in
            Task {
                guard let newItem else { return }
                guard let data = try? await newItem.loadTransferable(type: Data.self) else { return }
                selectedImageData = data
                selectedThumbnailData = generateThumbnail(from: data, maxDimension: 300)
            }
        }
    }

    private func generateThumbnail(from data: Data, maxDimension: CGFloat) -> Data? {
        guard let image = UIImage(data: data) else { return nil }

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

#Preview {
    @Previewable @State var imageData: Data? = nil
    @Previewable @State var thumbnailData: Data? = nil

    PhotoPickerView(
        selectedImageData: $imageData,
        selectedThumbnailData: $thumbnailData
    )
    .padding(16)
}
