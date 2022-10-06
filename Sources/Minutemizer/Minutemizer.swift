import Combine
import Foundation

/// An opaque storage to facilitate working with minutemen list
///
/// Useful to store, modify the list, generate a random ``Minuteman`` and collect statistics
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
public struct Minutemizer {

    var storage: UserDefaults = .standard
    static let lastMinutemanKey = "last minuteman"
    static let minutemenListKey = "minutemen list"

    private static let encoder = JSONEncoder()
    private static let decoder = JSONDecoder()
    private var subscriptions = Set<AnyCancellable>()

    /// Current list of minutemen
    public lazy var currentList = storage
        .publisher(for: \.minutemenList)
        .compactMap { $0 }
        .decode(type: [Minuteman].self, decoder: Self.decoder)
        .eraseToAnyPublisher()

    /// Last picked minuteman if any
    public lazy var lastPicked = storage
        .publisher(for: \.lastMinuteman)
        .compactMap { $0 }
        .decode(type: Minuteman.self, decoder: Self.decoder)
        .eraseToAnyPublisher()

    /// Picks a new minuteman from the list
    ///
    /// Also updates the ``lastPicked`` minuteman
    /// - Returns: A chosen minuteman or `nil` if the list is empty
    public mutating func pickOne() throws -> Minuteman? {
        let picked = try storage.minutemenList.flatMap { data in
            let list = try Self.decoder.decode([Minuteman].self, from: data)
            return list.randomElement()
        }
        let pickedData = try Self.encoder.encode(picked)
        storage.set(pickedData, forKey: Self.lastMinutemanKey)
        return picked
    }
}

// MARK: - Handling the list
@available(watchOS 6.0, *)
@available(tvOS 13.0, *)
@available(macOS 10.15, *)
@available(iOS 13.0, *)
public extension Minutemizer {

    /// Add a new minuteman to the list
    /// - Parameter minuteman: Minuteman to be added
    func add(_ minuteman: Minuteman) throws {
        try add([minuteman])
    }

    /// Add a list of minutemen to the current list
    /// - Parameter minutemen: List of minutemen to be added
    func add(_ minutemen: [Minuteman]) throws {
        let storedList = try storage.minutemenList.flatMap { data in
            try Self.decoder.decode([Minuteman].self, from: data)
        }
        let updatedList: [Minuteman]
        if let storedList {
            updatedList = storedList + minutemen
        } else {
            updatedList = minutemen
        }
        let updatedData = try Self.encoder.encode(updatedList)
        storage.set(updatedData, forKey: Self.minutemenListKey)
    }

    /// Delete a minuteman from the list
    /// - Parameter minuteman: Minuteman to be deleted
    func delete(_ minuteman: Minuteman) throws {
        try delete([minuteman])
    }

    /// Delete a list of minutemen from the current list
    /// - Parameter minutemen: List of minutemen to be deleted
    func delete(_ minutemen: [Minuteman]) throws {
        let storedList = try storage.minutemenList.flatMap { data in
            try Self.decoder.decode([Minuteman].self, from: data)
        }
        guard var storedList, !storedList.isEmpty else {
            throw MinutemizerError.emptyList
        }
        minutemen.forEach { minuteman in
            storedList.removeAll { $0 == minuteman }
        }
        let updatedData = try Self.encoder.encode(storedList)
        storage.set(updatedData, forKey: Self.minutemenListKey)
    }

    /// Completely delete all minutemen from the list
    func deleteAll() {
        storage.removeObject(forKey: Self.minutemenListKey)
        storage.removeObject(forKey: Self.lastMinutemanKey)
    }
}

// MARK: - Other
extension UserDefaults {
    @objc dynamic var minutemenList: Data? {
        data(forKey: "minutemen list")
    }

    @objc dynamic var lastMinuteman: Data? {
        data(forKey: "last minuteman")
    }
}
