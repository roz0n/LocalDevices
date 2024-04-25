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
  
  @State private var isPresented: Bool = false
  @State private var selectedItem: LocalNetworkDeviceViewModel? = nil
  
  var body: some View {
    List {
      if !listViewModel.devices.isEmpty {
        Section("Discovered Devices") {
          ForEach(listViewModel.devices) { deviceViewModel in
            LocalDeviceCellView(viewModel: deviceViewModel)
              .onTapGesture {
                selectedItem = deviceViewModel
                isPresented = true
              }
          }
        }
      }
    }
    .navigationTitle("LocalDevices")
    .navigationBarTitleDisplayMode(.inline)
    .confirmationDialog("Device Commands",
                        isPresented: $isPresented,
                        presenting: selectedItem,
                        actions: { item in
      Button {
        print("Tapped open drawer")
      } label: {
        Text("Open Drawer (TCP)")
      }
      
      Button(role: .cancel) {
        isPresented = false
        selectedItem = nil
      } label: {
        Text("Cancel")
      }
    }, message: { item in
      Text("Select a command to issue to the device.")
    })
    .overlay {
      if listViewModel.devices.isEmpty {
        ContentUnavailableView("Discovering Devices",
                               systemImage: "network",
                               description: Text("Devices in your local network will appear here as they announce."))
      }
    }
  }
}

#Preview {
  HomeView()
}
