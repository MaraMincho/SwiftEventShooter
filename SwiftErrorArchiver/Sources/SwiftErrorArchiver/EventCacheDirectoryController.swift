//
//  EventCacheDirectoryController.swift
//  SwiftErrorArchiver
//
//  Created by MaraMincho on 12/20/24.
//

import Foundation

public actor EventCacheDirectoryController: EventStorageControllerInterface, Sendable {
  private let logsDirectory: URL
  public init?(logsDirectoryURLString: String) {
    guard let url = URL(string: logsDirectoryURLString) else {
      return nil
    }
    logsDirectory = url
    initialConfigure()
  }

  public init?(storageControllerType: StorageControllerType) {
    guard let directoryURL = switch storageControllerType {
    case .failedNetworking:
      FileManagerUtility.networkingFailedLogDirectory
    case .nowNetworking:
      FileManagerUtility.logsDirectory
    }else {
      return nil
    }
    logsDirectory = directoryURL.appendingPathExtension(Constants.defaultDirectoryURL)
    initialConfigure()
  }

  nonisolated private func initialConfigure() {
    let fileManager = FileManager.default
    let fileDirectoryString = logsDirectory.absoluteString
    if fileManager.fileExists(atPath: fileDirectoryString) {
      try! fileManager.createDirectory(atPath: fileDirectoryString, withIntermediateDirectories: true)
    }
  }

  public func save(event: some EventInterface) throws -> String {
    let jsonData = try JSONEncoder.encode(event)
    let event = EventWithDate(data: jsonData)
    let (filePath, fileName) = filePath(for: event)
    try jsonData.write(to: filePath)
    return fileName
  }

  public func getEvent(from fileName: String) -> EventWithDate? {
    let filePath = logsDirectory.appendingPathComponent(fileName)
    do {
      let data = try Data(contentsOf: filePath)
      return try JSONDecoder.decode(EventWithDate.self, from: data)
    } catch {
      print("Failed to load event from \(fileName): \(error)")
      return nil
    }
  }

  public func delete(fileName: String) {
    let manager = FileManager.default
    do {
      try manager.removeItem(atPath: logsDirectory.appendingPathComponent(fileName).path)
    } catch {
      print("Failed to delete event: \(error)")
    }
  }

  public func getAllEventFileNames() -> [String] {
    do {
      let files = try FileManager.default.contentsOfDirectory(atPath: logsDirectory.path)
      return files
    } catch {
      print(logsDirectory)
      print("Failed to get log file names: \(error.localizedDescription)")
      return []
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
  enum DirectoryType {
    case nowNetworking
    case failed
    var directoryURL: URL? {
      switch self {
      case .nowNetworking:
        FileManagerUtility.logsDirectory
      case .failed:
        FileManagerUtility.networkingFailedLogDirectory
      }
    }
  }

  public enum StorageControllerType {
    case nowNetworking
    case failedNetworking
  }
}

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
