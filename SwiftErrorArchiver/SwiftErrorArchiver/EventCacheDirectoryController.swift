//
//  EventCacheDirectoryController.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

actor EventCacheDirectoryController: EventStorageControllerInterface, Sendable {
  func delete(event: some EventWithDateInterface) {
    let filePath = filePath(for: event)
    let manager = FileManager.default
    do {
      try manager.removeItem(at: filePath)
      print("Deleted file \(event.event)")
    } catch {
      print("Failed to delete event: \(error)")
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

  func getEvent<Event: EventWithDateInterface>(from fileName: String) -> Event? {
    let filePath = logsDirectory.appendingPathComponent(fileName)
    do {
      let data = try Data(contentsOf: filePath)
      return try JSONDecoder.decode(Event.self, from: data)
    } catch {
      print("Failed to load event from \(fileName): \(error)")
      return nil
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

  let logsDirectory: URL

  init?(logsDirectoryURLString: String = Constants.defaultDirectoryURL) {
    guard let url = URL(string: logsDirectoryURLString) else {
      return nil
    }
    logsDirectory = url
  }

  func save(event: some EventWithDateInterface) {
    let filePath = filePath(for: event)
    guard let jsonData = try? JSONEncoder.encode(event) else {
      print("JSON encoding error occurred")
      return
    }

    do {
      try jsonData.write(to: filePath)
    } catch {
      print("Failed to save event: \(error)")
    }
  }

  private func filePath(for event: some EventWithDateInterface) -> URL {
    let dateWithIntDescription = Int(event.date).description
    let uniqueIdentifier = UUID().description
    let fileName = [dateWithIntDescription, uniqueIdentifier].joined(separator: "_")
    return logsDirectory.appendingPathComponent("\(fileName).json")
  }

  private enum Constants {
    static let defaultDirectoryURL = "Logs/Error"
  }
}
