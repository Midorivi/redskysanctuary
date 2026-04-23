import SwiftUI
import SwiftData

struct AnimalDetailView: View {
    let animal: Animal

    @State private var selectedPhoto: AnimalPhoto?

    // MARK: - Computed Properties

    private var primaryPhoto: AnimalPhoto? {
        animal.photos?.first(where: { $0.isPrimary }) ?? animal.photos?.first
    }

    private var sortedPhotos: [AnimalPhoto] {
        (animal.photos ?? []).sorted { $0.dateAdded > $1.dateAdded }
    }

    private var latestHealthRecords: [HealthRecord] {
        (animal.healthRecords ?? [])
            .sorted { $0.date > $1.date }
            .prefix(3)
            .map { $0 }
    }

    private var activeHealthSigns: [HealthSign] {
        (animal.healthSigns ?? []).filter { !$0.isResolved }
    }

    private var upcomingReminders: [Reminder] {
        (animal.reminders ?? [])
            .filter { !$0.isCompleted && $0.date >= .now }
            .sorted { $0.date < $1.date }
    }

    private var isInactive: Bool {
        animal.status != AnimalStatus.active
    }

    private var statusLabel: String {
        animal.status.capitalized
    }

    private var statusColor: Color {
        switch animal.status {
        case AnimalStatus.active: .green
        case AnimalStatus.deceased: .gray
        case AnimalStatus.adopted: .blue
        case AnimalStatus.transferred: .orange
        default: .secondary
        }
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                if isInactive {
                    statusBanner
                }

                headerSection

                if !sortedPhotos.isEmpty {
                    photoGallerySection
                }

                infoSection

                feedingSection

                healthSummarySection

                healthSignsSection

                remindersSection
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .padding(.bottom, 24)
        }
        .background(Color(.systemBackground))
        .navigationTitle(animal.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    AnimalFormView(animal: animal)
                } label: {
                    Text("Edit")
                }
            }
        }
        .opacity(isInactive ? 0.85 : 1.0)
        .sheet(item: $selectedPhoto) { photo in
            PhotoDetailSheet(photo: photo)
        }
    }

    // MARK: - Status Banner

    private var statusBanner: some View {
        HStack(spacing: 8) {
            Image(systemName: statusBannerIcon)
                .symbolRenderingMode(.hierarchical)
            Text("This animal is \(animal.status)")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(statusColor)
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(statusColor.opacity(0.12))
        .clipShape(.rect(cornerRadius: 10, style: .continuous))
    }

    private var statusBannerIcon: String {
        switch animal.status {
        case AnimalStatus.deceased: "heart.slash"
        case AnimalStatus.adopted: "house.fill"
        case AnimalStatus.transferred: "arrow.right.circle.fill"
        default: "info.circle.fill"
        }
    }

    // MARK: - Header

    private var headerSection: some View {
        VStack(spacing: 12) {
            if let imageData = primaryPhoto?.imageData,
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
            } else {
                Image(systemName: "pawprint.fill")
                    .font(.system(size: 44))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.blue)
                    .frame(width: 120, height: 120)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Circle())
            }

            VStack(spacing: 4) {
                Text(animal.displayName)
                    .font(.system(.largeTitle, design: .rounded).bold())
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
                        .font(.footnote)
                        .foregroundStyle(.tertiary)
                }
            }

            if isInactive {
                Text(statusLabel)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(statusColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(statusColor.opacity(0.12))
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
    }

    // MARK: - Photo Gallery

    private var photoGallerySection: some View {
        GroupBox {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(sortedPhotos) { photo in
                        Button {
                            selectedPhoto = photo
                        } label: {
                            photoThumbnail(photo)
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.selection, trigger: selectedPhoto)
                    }
                }
            }
        } label: {
            Label("Photos", systemImage: "photo.on.rectangle")
        }
    }

    private func photoThumbnail(_ photo: AnimalPhoto) -> some View {
        Group {
            if let thumbnailData = photo.thumbnailData,
               let uiImage = UIImage(data: thumbnailData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else if let imageData = photo.imageData,
                      let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                Image(systemName: "photo")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: 80, height: 80)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(photo.isPrimary ? Color.blue : .clear, lineWidth: 2)
        )
    }

    // MARK: - Info Section

    private var infoSection: some View {
        GroupBox {
            VStack(spacing: 0) {
                if let birthday = animal.birthday {
                    infoRow(
                        icon: "birthday.cake",
                        label: "Birthday",
                        value: birthday.formatted(date: .long, time: .omitted)
                    )
                    Divider()
                }

                infoRow(
                    icon: "calendar.badge.plus",
                    label: "Date Added",
                    value: animal.dateAdded.formatted(date: .long, time: .omitted)
                )
                Divider()

                infoRow(
                    icon: "circle.fill",
                    iconColor: statusColor,
                    label: "Status",
                    value: statusLabel
                )

                if let notes = animal.notes, !notes.isEmpty {
                    Divider()
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Image(systemName: "note.text")
                                .foregroundStyle(.secondary)
                                .frame(width: 24)
                            Text("Notes")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .padding(.leading, 32)
                    }
                    .padding(.vertical, 10)
                }
            }
        } label: {
            Label("Information", systemImage: "info.circle")
        }
    }

    private func infoRow(
        icon: String,
        iconColor: Color = .secondary,
        label: String,
        value: String
    ) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .frame(width: 24)
            Text(label)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundStyle(.primary)
        }
        .padding(.vertical, 10)
    }

    // MARK: - Feeding Instructions

    private var feedingSection: some View {
        GroupBox {
            if let instructions = animal.feedingInstructions, !instructions.isEmpty {
                Text(instructions)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                HStack(spacing: 8) {
                    Image(systemName: "fork.knife")
                        .foregroundStyle(.tertiary)
                    Text("No feeding instructions")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } label: {
            Label("Feeding Instructions", systemImage: "fork.knife")
        }
    }

    // MARK: - Health Summary

    private var healthSummarySection: some View {
        GroupBox {
            if latestHealthRecords.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "heart.text.clipboard")
                        .foregroundStyle(.tertiary)
                    Text("No health records")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(latestHealthRecords.enumerated()), id: \.element.id) { index, record in
                        healthRecordRow(record)
                        if index < latestHealthRecords.count - 1 {
                            Divider()
                        }
                    }

                    if (animal.healthRecords?.count ?? 0) > 3 {
                        Divider()
                        NavigationLink {
                            HealthRecordListView(animal: animal)
                        } label: {
                            HStack {
                                Text("View All")
                                    .font(.subheadline.weight(.medium))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundStyle(.tertiary)
                            }
                            .padding(.vertical, 10)
                        }
                    }
                }
            }
        } label: {
            Label("Health Summary", systemImage: "heart.text.clipboard")
        }
    }

    private func healthRecordRow(_ record: HealthRecord) -> some View {
        HStack(spacing: 10) {
            Image(systemName: healthRecordIcon(for: record.recordType))
                .foregroundStyle(.blue)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(record.title.isEmpty ? record.recordType.capitalized : record.title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(record.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(record.recordType.replacingOccurrences(of: "_", with: " ").capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(Color(.tertiarySystemBackground))
                .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }

    private func healthRecordIcon(for type: String) -> String {
        switch type {
        case RecordType.vaccination: "syringe"
        case RecordType.vetVisit: "stethoscope"
        case RecordType.treatment: "cross.case"
        case RecordType.checkup: "heart.text.clipboard"
        case RecordType.injury: "bandage"
        case RecordType.illness: "pills"
        default: "heart.text.clipboard"
        }
    }

    // MARK: - Active Health Signs

    private var healthSignsSection: some View {
        GroupBox {
            if activeHealthSigns.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.seal")
                        .foregroundStyle(.green)
                    Text("No active concerns")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(activeHealthSigns.enumerated()), id: \.element.id) { index, sign in
                        healthSignRow(sign)
                        if index < activeHealthSigns.count - 1 {
                            Divider()
                        }
                    }
                }
            }
            Divider()
            NavigationLink {
                HealthSignListView(animal: animal)
            } label: {
                HStack {
                    Text("View All Signs")
                        .font(.subheadline.weight(.medium))
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 10)
            }
        } label: {
            Label("Active Health Signs", systemImage: "exclamationmark.triangle")
        }
    }

    private func healthSignRow(_ sign: HealthSign) -> some View {
        HStack(spacing: 10) {
            Circle()
                .fill(severityColor(sign.severity))
                .frame(width: 10, height: 10)
            VStack(alignment: .leading, spacing: 2) {
                Text(sign.symptom)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text("Since \(sign.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(sign.severity.capitalized)
                .font(.caption.weight(.medium))
                .foregroundStyle(severityColor(sign.severity))
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(severityColor(sign.severity).opacity(0.12))
                .clipShape(Capsule())
        }
        .padding(.vertical, 8)
    }

    private func severityColor(_ severity: String) -> Color {
        switch severity {
        case Severity.mild: .green
        case Severity.moderate: .yellow
        case Severity.severe: .red
        default: .gray
        }
    }

    // MARK: - Reminders

    private var remindersSection: some View {
        GroupBox {
            if upcomingReminders.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "bell.slash")
                        .foregroundStyle(.tertiary)
                    Text("No reminders")
                        .font(.subheadline)
                        .foregroundStyle(.tertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(upcomingReminders.enumerated()), id: \.element.id) { index, reminder in
                        reminderRow(reminder)
                        if index < upcomingReminders.count - 1 {
                            Divider()
                        }
                    }
                }
            }
        } label: {
            Label("Reminders", systemImage: "bell.fill")
        }
    }

    private func reminderRow(_ reminder: Reminder) -> some View {
        HStack(spacing: 10) {
            Image(systemName: reminder.isRecurring ? "arrow.triangle.2.circlepath" : "bell")
                .foregroundStyle(.orange)
                .symbolRenderingMode(.hierarchical)
                .frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(reminder.title)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                Text(reminder.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            if reminder.isRecurring, let pattern = reminder.recurrencePattern {
                Text(pattern.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(Capsule())
            }
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Photo Detail Sheet

private struct PhotoDetailSheet: View {
    let photo: AnimalPhoto
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()

                if let imageData = photo.imageData,
                   let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 4, style: .continuous))
                } else {
                    ContentUnavailableView(
                        "No Image",
                        systemImage: "photo",
                        description: Text("Image data unavailable")
                    )
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .foregroundStyle(.white)
                            .font(.title2)
                    }
                }

                if let caption = photo.caption, !caption.isEmpty {
                    ToolbarItem(placement: .bottomBar) {
                        Text(caption)
                            .font(.footnote)
                            .foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .toolbarBackground(.hidden, for: .navigationBar)
        }
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(20)
    }
}

// MARK: - Preview

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(
        for: Animal.self,
        configurations: config
    )

    let animal = Animal(
        name: "Maple",
        animalType: "horse",
        breed: "Quarter Horse",
        birthday: Calendar.current.date(byAdding: .year, value: -5, to: .now),
        feedingInstructions: "2 flakes of hay twice daily. Supplement with senior feed in the evening. Fresh water always available.",
        notes: "Maple is a gentle rescue horse who arrived in 2021. She is very friendly and loves carrots."
    )
    container.mainContext.insert(animal)

    let record1 = HealthRecord(
        date: Calendar.current.date(byAdding: .day, value: -14, to: .now)!,
        recordType: RecordType.vetVisit,
        title: "Annual Checkup",
        veterinarian: "Dr. Thompson",
        animal: animal
    )
    let record2 = HealthRecord(
        date: Calendar.current.date(byAdding: .month, value: -2, to: .now)!,
        recordType: RecordType.vaccination,
        title: "West Nile Vaccine",
        animal: animal
    )
    container.mainContext.insert(record1)
    container.mainContext.insert(record2)

    let sign = HealthSign(
        symptom: "Slight limp on left foreleg",
        severity: Severity.moderate,
        animal: animal
    )
    container.mainContext.insert(sign)

    let reminder = Reminder(
        title: "Farrier Visit",
        date: Calendar.current.date(byAdding: .day, value: 7, to: .now)!,
        isRecurring: true,
        recurrencePattern: ReminderRecurrence.monthly,
        relatedAnimal: animal
    )
    container.mainContext.insert(reminder)

    return NavigationStack {
        AnimalDetailView(animal: animal)
    }
    .modelContainer(container)
}
