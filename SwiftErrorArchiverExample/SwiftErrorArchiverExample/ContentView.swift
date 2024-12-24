//
//  ContentView.swift
//  SwiftErrorArchiverExample
//
//  Created by MaraMincho on 12/23/24.
//

import SwiftUI
import SwiftErrorArchiver

struct ContentView: View {
  let sdk = SwiftErrorArchiverSDK(type:
      .discord(
        .init(
//          provider: .init(session: MockURLSession(completion: { request, delegate in
//            if Int.random(in: 1...2) % 2 == 0 {
//              throw NSError(domain: "에러 발생", code: 1)
//            }
//            return (Data(), .init())
//          })),
          discordNetworkURL: "https://discord.com/api/webhooks/1320723047363117116/p5wAgGLFkRYYRAYwdmQ5lBIp4TSCGozSB-F85k3of46i4_t9Sgt49an9GeATCvHHQ_nG"
        )
      )
  )

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
        for ind in 1...100 {
          sdk.sendMessage(event: TestEventObject(message: "\(ind)Message입니다."))
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

struct TestEventObject: EventInterface {
  let message: String
}
