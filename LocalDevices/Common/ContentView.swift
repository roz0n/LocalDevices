//
//  ContentView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import SwiftUI

struct ContentView: View {
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
    .onAppear {
      let provider = NetworkConnectionProvider(protocol: .udp)
      _ = NetworkDeviceService(host: .ipv4(.broadcast),
                                         port: 10004,
                                         provider: provider)
    }
  }
}

#Preview {
  ContentView()
}
