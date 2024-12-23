//
//  ContentView.swift
//  SwiftErrorArchiverExample
//
//  Created by MaraMincho on 12/23/24.
//

import SwiftUI
import SwiftErrorArchiver

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")

      Button {
        fatalError()
      } label: {
        Text("fatal error occurred")
      }

    }
    .padding()
  }
}
