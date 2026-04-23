import SwiftUI
import SwiftData

@Observable
final class HealthViewModel {

    // MARK: - Health Records

    func addHealthRecord(
        to animal: Animal,
        recordType: String,
        title: String,
        date: Date = .now,
        notes: String? = nil,
        veterinarian: String? = nil,
        nextVisitDate: Date? = nil,
        in context: ModelContext
    ) {
        let record = HealthRecord(
            date: date,
            recordType: recordType,
            title: title,
            notes: notes,
            veterinarian: veterinarian,
            nextVisitDate: nextVisitDate,
            animal: animal
        )
        context.insert(record)
    }

    func deleteHealthRecord(_ record: HealthRecord, in context: ModelContext) {
        context.delete(record)
    }

    // MARK: - Health Signs

    func addHealthSign(
        to animal: Animal,
        symptom: String,
        severity: String = Severity.mild,
        date: Date = .now,
        notes: String? = nil,
        in context: ModelContext
    ) {
        let sign = HealthSign(
            date: date,
            symptom: symptom,
            severity: severity,
            notes: notes,
            animal: animal
        )
        context.insert(sign)
    }

    func resolveHealthSign(_ sign: HealthSign) {
        sign.isResolved = true
        sign.resolvedDate = .now
    }

    func deleteHealthSign(_ sign: HealthSign, in context: ModelContext) {
        context.delete(sign)
    }

    // MARK: - Filtering

    func filteredRecords(for animal: Animal, by recordType: String?) -> [HealthRecord] {
        let allRecords = (animal.healthRecords ?? [])
            .sorted { $0.date > $1.date }

        guard let recordType, !recordType.isEmpty else {
            return allRecords
        }

        return allRecords.filter { $0.recordType == recordType }
    }
}
