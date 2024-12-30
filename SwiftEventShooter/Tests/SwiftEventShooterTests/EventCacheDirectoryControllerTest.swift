//
//  EventCacheDirectoryControllerTest.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/28/24.
//

import XCTest
@testable import SwiftEventShooter

final class EventCacheDirectoryControllerTest: XCTestCase {
  var controller: EventCacheDirectoryController! = nil
  override func setUp() async throws {
    try super.setUpWithError()
    controller = .init(storageControllerType: .discord(.nowNetworking))
    await controller.deleteAllEventFromDirectory()
  }

  override func tearDownWithError() throws {
    controller = nil
  }

  struct TestEvent: Codable, Equatable {
    let message: String
    let id: UUID

    init(message: String) {
      id = .init()
      self.message = message
    }
  }

  func test_ActFile() async throws {
    let testEventMessage = "I am test event message"
    let willSaveEvent = TestEvent(message: testEventMessage)
    _ = try await controller.save(event: willSaveEvent)
    let eventFileNames = await controller.getAllEventFileNames()
    // Test is saved
    XCTAssertEqual(eventFileNames.count, 1)

    // Test load file is equal with prev init object
    let savedFileName = eventFileNames.first!
    let currentEventData = await controller.getEvent(from: savedFileName)!.data
    let eventObject = try! JSONDecoder().decode(TestEvent.self, from: currentEventData)
    XCTAssertEqual(willSaveEvent, eventObject)
    await controller.delete(fileName: savedFileName)

    // Test is deleted
    let fileNamesAfterDeletedNewFile = await controller.getAllEventFileNames()
    XCTAssertTrue(fileNamesAfterDeletedNewFile.isEmpty)

  }

}
