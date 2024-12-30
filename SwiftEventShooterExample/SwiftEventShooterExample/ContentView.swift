//
//  ContentView.swift
//  SwiftErrorArchiverExample
//
//  Created by MaraMincho on 12/23/24.
//

import SwiftEventShooter
import SwiftUI

// MARK: - ContentView

struct ContentView: View {
  /// Type the your discord url String
  let sdk = SwiftErrorArchiverSDK(type: .discord(.init(discordNetworkURL: "Any Discord WebHook URL")))

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")

      Button {
        sdk.sendMessage(event: "안녕하세요")
      } label: {
        Text("fatal error occurred")
      }

      Button {
        for ind in 1 ... 100 {
          sdk.sendMessage(event: TestEventObject(message: "\(ind)Message입니다."))
          sdk.sendMessage(event: "Hello world")
        }
      } label: {
        Text("fatal error occurred")
      }
    }
    .task {
      sdk.configure()
    }
    .padding()
  }
}

// MARK: - TestEventObject

struct TestEventObject: EventInterface {
  let message: String
}
