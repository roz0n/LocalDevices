//
//  HomeView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import SwiftUI
import Combine

struct HomeView: View {
  
  @StateObject private var listViewModel = NetworkDeviceListViewModel()
  
  var body: some View {
    List {
      if !listViewModel.devices.isEmpty {
        Section("Discovered Devices") {
          ForEach(listViewModel.devices) { deviceViewModel in
            LocalDeviceCellView(viewModel: deviceViewModel)
          }
        }
      }
    }
    .navigationTitle("LocalDevices")
    .navigationBarTitleDisplayMode(.inline)
    .overlay {
      if listViewModel.devices.isEmpty {
        ContentUnavailableView("Searching for Devices",
                               systemImage: "network",
                               description: Text("Devices in your local network will appear here as they are discovered."))
      }
    }
  }
}

#Preview {
  HomeView()
}
