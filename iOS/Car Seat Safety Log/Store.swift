import Foundation
import Combine

@MainActor
final class Store: ObservableObject {
    @Published private(set) var items: [CarSeat] = []
    @Published var categoryFilterEnabled: Bool = true

    /// Free tier item cap. Kept comfortably above seed data count so a
    /// fresh install never trips the paywall on first launch.
    static let freeItemLimit = 8

    private let fileURL: URL

    init() {
        let support = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        try? FileManager.default.createDirectory(at: support, withIntermediateDirectories: true)
        fileURL = support.appendingPathComponent("carseatlog_items.json")
        load()
        if items.isEmpty {
            seed()
        }
    }

    var isAtFreeLimit: Bool {
        items.count >= Store.freeItemLimit
    }

    func canAdd(isPro: Bool) -> Bool {
        isPro || items.count < Store.freeItemLimit
    }

    func add(title: String, detail: String = "") {
        let item = CarSeat(title: title, detail: detail)
        items.insert(item, at: 0)
        save()
    }

    func update(_ item: CarSeat) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx] = item
        save()
    }

    func delete(at offsets: IndexSet) {
        items.remove(atOffsets: offsets)
        save()
    }

    func delete(_ item: CarSeat) {
        items.removeAll { $0.id == item.id }
        save()
    }

    func toggleDone(_ item: CarSeat) {
        guard let idx = items.firstIndex(where: { $0.id == item.id }) else { return }
        items[idx].isDone.toggle()
        save()
    }

    private func seed() {
        items = [
            CarSeat(title: "First entry", detail: "Sample seeded record"),
            CarSeat(title: "Second entry", detail: "Another sample record")
        ]
        save()
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL) else { return }
        if let decoded = try? JSONDecoder().decode([CarSeat].self, from: data) {
            items = decoded
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(items) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
