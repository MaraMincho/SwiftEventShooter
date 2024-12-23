//
//  ContentView.swift
//  SwiftErrorArchiverExample
//
//  Created by MaraMincho on 12/23/24.
//

import SwiftUI
import SwiftErrorArchiver

struct ContentView: View {
  let sdk = SwiftErrorArchiverSDK(type: .discord(.init(discordNetworkURL: "https://discord.com/api/webhooks/1320723047363117116/p5wAgGLFkRYYRAYwdmQ5lBIp4TSCGozSB-F85k3of46i4_t9Sgt49an9GeATCvHHQ_nG")))

  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")

      Button {
        sdk.sendMessage(event: "SomeEvent")
      } label: {
        Text("fatal error occurred")
      }
    }
    .padding()
  }
}

struct TestEventObject: EventInterface {
  let message: String
}
