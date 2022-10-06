import XCTest
import Combine
@testable import Minutemizer

@available(tvOS 13.0, *)
@available(iOS 13.0, *)
final class MinutemizerTests: XCTestCase {
    var minutemizer: Minutemizer!
    var subscriptions = Set<AnyCancellable>()

    override func setUp() {
        minutemizer = .init()
        let testStorage = UserDefaults(suiteName: "UnitTest")
        minutemizer.storage = testStorage!
    }

    override func tearDown() {
        minutemizer.storage.removePersistentDomain(forName: "UnitTest")
        subscriptions = []
    }

    func test_currentList_empty() throws {
        var result = [Minuteman]()
        minutemizer.currentList
            .sink { completion in
                XCTFail(String(describing: completion))
            } receiveValue: { list in
                result = list
            }
            .store(in: &subscriptions)
        XCTAssertTrue(result.isEmpty)
    }

    func test_currentList_notEmpty() throws {
        let count = 2
        try addTestValue(count: count)
        var result = [Minuteman]()

        minutemizer.currentList
            .sink { completion in
                XCTFail(String(describing: completion))
            } receiveValue: { list in
                result = list
            }
            .store(in: &subscriptions)
        XCTAssertFalse(result.isEmpty)
        XCTAssertEqual(result.count, count)
    }

    func test_lastPicked_nil() throws {
        var result: Minuteman?
        minutemizer.lastPicked
            .sink { completion in
                XCTFail(String(describing: completion))
            } receiveValue: { last in
                result = last
            }
            .store(in: &subscriptions)
        XCTAssertNil(result)
    }

    func test_pickOne_nil() throws {
        let stored = try minutemizer.pickOne()
        XCTAssertNil(stored)
    }

    func test_pickOne_notNil() throws {
        try addTestValue()
        let stored = try minutemizer.pickOne()
        XCTAssertNotNil(stored)
    }
}

@available(tvOS 13.0, *)
@available(iOS 13.0, *)
extension MinutemizerTests {
    func addTestValue(count: Int = 1) throws {
        let testMinutemen = (0 ..< count).map { _ in
            Minuteman(
                firstName: "Harry",
                secondName: "Potter",
                middleName: "James"
            )
        }
        let testData = try JSONEncoder().encode(testMinutemen)
        minutemizer.storage.set(
            testData,
            forKey: Minutemizer.minutemenListKey
        )
    }
}
