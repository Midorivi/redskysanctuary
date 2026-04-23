import SwiftUI

struct FormField: View {
    let label: String
    var placeholder: String = ""
    @Binding var text: String
    var isMultiline: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            if isMultiline {
                TextEditor(text: $text)
                    .frame(minHeight: 100)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
            } else {
                TextField(placeholder, text: $text)
                    .padding(12)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(.rect(cornerRadius: 8, style: .continuous))
            }
        }
    }
}

#Preview {
    @Previewable @State var name = ""
    @Previewable @State var notes = "Some existing notes about this animal."

    VStack(spacing: 16) {
        FormField(
            label: "Animal Name",
            placeholder: "Enter name",
            text: $name
        )

        FormField(
            label: "Notes",
            placeholder: "Enter notes",
            text: $notes,
            isMultiline: true
        )
    }
    .padding(16)
}
