//
//  File.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/28/24.
//

@testable import SwiftErrorArchiver
import XCTest

// MARK: - LogControllerTest

/// White box tests
final class SlackControllerTest: XCTestCase {
  var controller: EventControllerInterface!

  override func setUpWithError() throws {
    try super.setUpWithError()
  }

  override func tearDownWithError() throws {
    try super.tearDownWithError()
    controller = nil
  }

  /// Log전달 실패시 Log 저장 로직이 정상적으로 동작하는지 테스트합니다.
  /// <0초 후에> 첫 싸이클에서 테스크 20개 전달, Task 10개는 Fail, 10개는 성공
  /// <8초 후에> 두번째 Timer를 통해 실패한 Log 10개를 전달, 10개 모두 성공
  func test_withMockStruct() async throws {
    // Arrange
    let event = TestEvent(message: "Some Category")
    let storageController: EventStorageControllerInterface = TestStorageController()
    let failedStorageController: EventStorageControllerInterface = TestStorageController()
    let message = "{\"message\": \"OK\"}".data(using: .utf8)!
    var availableFailCount = 10
    let taskCount = 20
    let expectation1: XCTestExpectation = .init()
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      expectation1.fulfill()
    }
    let expectation2: XCTestExpectation = .init()
    DispatchQueue.main.asyncAfter(deadline: .now() + 20) {
      expectation2.fulfill()
    }
    let mockSession = MockURLSession(completion: { request, delegate in
      if availableFailCount > 0 {
        availableFailCount -= 1
        throw TestError(errorDescription: availableFailCount.description)
      }
      return (message, .init())
    })
    controller = SlackErrorStreamController(
      provider: .init(session: mockSession),
      slackWebHookURL: "https://exmpale.com",
      nowNetworkingStorageController: storageController,
      networkingFailedStorageController: failedStorageController,
      timeInterval: 1,
      pendingStreamManager: CountedBasedPendingStreamManager(capacity: 20),
      networkMonitor: MockNetworkMonitor()
    )

    // Act
    for _ in 0 ..< taskCount {
        await controller.post(event)
    }
    controller.configure()

    // Assert
    await fulfillment(of: [expectation1], timeout: 10)
    await fulfillment(of: [expectation2], timeout: 25)
    let nowNetworkingFileNames = await storageController.getAllEventFileNames()
    let networkingFailedFileNames = await failedStorageController.getAllEventFileNames()
    XCTAssertEqual([], nowNetworkingFileNames)
    XCTAssertEqual([], networkingFailedFileNames)
  }

  /// 이전에 저장했던 로그들을 pendding하여 보내는것을 테스트 합니다.
  func test_storageTest() async throws {
    // Arrange
    let event = TestEvent(message: "Some Category")
    let eventData = try! JSONEncoder.encode(event)
    let eventWithDates = (0 ... 30).map { _ in EventWithDate(data: eventData)}
    let storageController: EventStorageControllerInterface = TestStorageController(eventWithDates: eventWithDates)
    let failedStorageController: EventStorageControllerInterface = TestStorageController()
    let expectation: XCTestExpectation = .init()
    DispatchQueue.main.asyncAfter(deadline: .now() + 30) {
      expectation.fulfill()
    }

    controller = SlackErrorStreamController(
      provider: .init(session: MockURLSession(), providerElement: .init(timeoutInterval: 1)),
      slackWebHookURL: "https://exmpale.com",
      nowNetworkingStorageController: storageController,
      networkingFailedStorageController: failedStorageController,
      timeInterval: 1,
      pendingStreamManager: CountedBasedPendingStreamManager(capacity: 50),
      networkMonitor: MockNetworkMonitor()
    )

    // Act
    controller.configure()
    // goes off timer

    // Assert
    await fulfillment(of: [expectation], timeout: 45)
    let nowNetworkingFileNames = await storageController.getAllEventFileNames()
    let failedNetworkingFileNames = await failedStorageController.getAllEventFileNames()
    XCTAssertEqual([], failedNetworkingFileNames)
    XCTAssertEqual([], nowNetworkingFileNames)
  }
}

extension SlackControllerTest {
  struct TestError: LocalizedError {
    var errorDescription: String?
  }
  var targetType: DiscordNetworkTargetType {
    .init(baseURL: "https//example.com", path: nil, method: .post, body: nil, headers: [:])
  }

  var provider: SDKNetworkProvider<DiscordNetworkTargetType> {
    .init(session: MockURLSession(completion: { request, delegate in
      return (Data(), .init())
    }))
  }

  final actor TestStorageController: @unchecked Sendable, EventStorageControllerInterface {
    var files: [UUID: EventWithDate] = [:]

    init(eventWithDates: [EventWithDate] = []) {

      for file in eventWithDates {
        files[file.id] = file
      }
    }

    let jsonDecoder = JSONDecoder()
    let jsonEncoder = JSONEncoder()
    func save(event: some Decodable & Encodable & Equatable & Sendable) -> String{
      let jsonData = try! jsonEncoder.encode(event)
      let eventWithDate = EventWithDate(data: jsonData)
      files[eventWithDate.id] = eventWithDate

      return eventWithDate.id.uuidString
    }


    func delete(fileName: String) {
      if let key = UUID(uuidString: fileName) {
        files.removeValue(forKey: key)
      }
    }

    func getEvent(from fileName: String) -> EventWithDate? {
      if let key = UUID(uuidString: fileName) {
        return files[key]
      }
      return nil
    }

    func getAllEventFileNames() -> [String] {
      return files.keys.map(\.description)
    }
    func deleteAllEventFromDirectory() {
      files.removeAll()
    }
  }

  struct TestEvent: Codable, Equatable {
    let message: String
  }
}
