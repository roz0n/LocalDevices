//
//  ContentView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import SwiftUI

struct ContentView: View {
  
  private var networkDeviceService = NetworkDeviceService(
    host: .ipv4(.broadcast),
    port: 10004,
    provider: NetworkConnectionProvider(protocol: .udp)
  )
  
  var body: some View {
    VStack {
      Image(systemName: "globe")
        .imageScale(.large)
        .foregroundStyle(.tint)
      Text("Hello, world!")
    }
    .padding()
  }
}

#Preview {
  ContentView()
}
