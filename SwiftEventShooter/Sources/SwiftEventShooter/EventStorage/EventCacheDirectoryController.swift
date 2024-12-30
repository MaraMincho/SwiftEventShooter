//
//  EventCacheDirectoryController.swift
//  SwiftEventShooter
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

// MARK: - EventCacheDirectoryController

public actor EventCacheDirectoryController: EventStorageControllerInterface, Sendable {
  private let logsDirectory: URL
  public init?(logsDirectoryURLString: String) {
    guard let url = URL(string: logsDirectoryURLString) else {
      return nil
    }
    logsDirectory = url
    initialConfigure()
  }

  public init?(storageControllerType type: PlatformType) {
    guard let directoryURL = type.directoryURL else {
      return nil
    }
    logsDirectory = directoryURL
    initialConfigure()
  }

  private nonisolated func initialConfigure() {
    let fileManager = FileManager.default
    let directoryPath = logsDirectory.path
    if !fileManager.fileExists(atPath: directoryPath) {
      try? fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true)
    }
  }

  public func save(event: some EventInterface) throws -> String {
    let jsonData = try JSONEncoder.encode(event)
    let event = EventWithDate(data: jsonData)
    let (filePath, fileName) = filePath(for: event)
    let eventJsonData = try JSONEncoder.encode(event)
    try eventJsonData.write(to: filePath)
    return fileName
  }

  public func getEvent(from fileName: String) -> EventWithDate? {
    let filePath = logsDirectory.appendingPathComponent(fileName)
    do {
      let data = try Data(contentsOf: filePath)
      return try JSONDecoder.decode(EventWithDate.self, from: data)
    } catch {
      SwiftEventShooterLogger.error(message: "Failed to load event from \(filePath): \(error)")
      return nil
    }
  }

  public func delete(fileName: String) {
    let manager = FileManager.default
    do {
      try manager.removeItem(atPath: logsDirectory.appendingPathComponent(fileName).path)
    } catch {
      SwiftEventShooterLogger.error(message: "Failed to delete event: \(error)")
    }
  }

  public func getAllEventFileNames() -> [String] {
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: logsDirectory.path)
      return files
    } catch {
      SwiftEventShooterLogger.error(message: "Failed to get log file names: \(error.localizedDescription)")
      return []
    }
  }

  public func deleteAllEventFromDirectory() {
    getAllEventFileNames().forEach { fileName in
      delete(fileName: fileName)
    }
  }

  private func filePath(for event: EventWithDate) -> (url: URL, fileName: String) {
    let dateWithIntDescription = Int(event.date).description
    let uniqueIdentifier = UUID().description
    let fileName = [dateWithIntDescription, uniqueIdentifier].joined(separator: "_") + ".json"
    return (logsDirectory.appendingPathComponent(fileName), fileName)
  }

  public enum Constants {
    public static let defaultDirectoryURL = "Logs/Error"
  }
}

// MARK: - PlatformType

public enum PlatformType {
  case discord(StorageControllerType)
  case slack(StorageControllerType)

  var directoryName: String {
    switch self {
    case .discord:
      "Discord"
    case .slack:
      "Slack"
    }
  }

  var directoryURL: URL? {
    switch self {
    case let .discord(type):
      type.directoryURL?.appendingPathComponent(directoryName)
    case let .slack(type):
      type.directoryURL?.appendingPathComponent(directoryName)
    }
  }
}

// MARK: - StorageControllerType

public enum StorageControllerType {
  case nowNetworking
  case failedNetworking
  var directoryURL: URL? {
    switch self {
    case .nowNetworking:
      FileManagerUtility.logsDirectory
    case .failedNetworking:
      FileManagerUtility.networkingFailedLogDirectory
    }
  }
}

// MARK: - FileManagerUtility

private enum FileManagerUtility {
  static var logsDirectory: URL? {
    let manager = FileManager.default
    guard let directory = manager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
      return nil
    }
    let logsPath = directory.appendingPathComponent("Logs/Networking")

    if !manager.fileExists(atPath: logsPath.path) {
      try? manager.createDirectory(at: logsPath, withIntermediateDirectories: true)
    }
    return logsPath
  }

  static var networkingFailedLogDirectory: URL? {
    let manager = FileManager.default
    guard let directory = manager.urls(for: .cachesDirectory, in: .userDomainMask).first else {
      return nil
    }
    let logsPath = directory.appendingPathComponent("Logs/FailedNetworking")

    if !manager.fileExists(atPath: logsPath.path) {
      try? manager.createDirectory(at: logsPath, withIntermediateDirectories: true)
    }
    return logsPath
  }
}
