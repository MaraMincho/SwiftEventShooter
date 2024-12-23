//
//  EventCacheDirectoryController.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

actor EventCacheDirectoryController: EventStorageControllerInterface, Sendable {
  let logsDirectory: URL
  init?(logsDirectoryURLString: String = Constants.defaultDirectoryURL) {
    guard let url = URL(string: logsDirectoryURLString) else {
      return nil
    }
    logsDirectory = url
  }

  func save(event: some EventInterface) {
    guard let jsonData = try? JSONEncoder.encode(event) else {
      print("JSON encoding error occurred")
      return
    }
    let event = EventWithDate(data: jsonData)
    let filePath = filePath(for: event)

    do {
      try jsonData.write(to: filePath)
    } catch {
      print("Failed to save event: \(error)")
    }
  }

  func getEvent(from fileName: String) -> EventWithDate? {
    let filePath = logsDirectory.appendingPathComponent(fileName)
    do {
      let data = try Data(contentsOf: filePath)
      return try JSONDecoder.decode(EventWithDate.self, from: data)
    } catch {
      print("Failed to load event from \(fileName): \(error)")
      return nil
    }
  }

  func delete(fileName: String) {
    let manager = FileManager.default
    do {
      try manager.removeItem(atPath: logsDirectory.appendingPathComponent(fileName).path)
    } catch {
      print("Failed to delete event: \(error)")
    }
  }

  func getAllEventFileNames() -> [String] {
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: logsDirectory.path)
      return files
    } catch {
      print("Failed to get log file names: \(error.localizedDescription)")
      return []
    }
  }

  private func filePath(for event: EventWithDate) -> URL {
    let dateWithIntDescription = Int(event.date).description
    let uniqueIdentifier = UUID().description
    let fileName = [dateWithIntDescription, uniqueIdentifier].joined(separator: "_")
    return logsDirectory.appendingPathComponent("\(fileName).json")
  }

  private enum Constants {
    static let defaultDirectoryURL = "Logs/Error"
  }
}
