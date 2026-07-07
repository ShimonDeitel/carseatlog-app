import Foundation

struct CarSeat: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var detail: String
    var date: Date
    var isDone: Bool

    init(id: UUID = UUID(), title: String, detail: String = "", date: Date = Date(), isDone: Bool = false) {
        self.id = id
        self.title = title
        self.detail = detail
        self.date = date
        self.isDone = isDone
    }
}
