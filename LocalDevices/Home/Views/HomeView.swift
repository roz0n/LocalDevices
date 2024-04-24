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
      Section("Discovered Devices") {
        ForEach(listViewModel.devices, id: \.self) { string in
          Text(string)
        }
      }
    }
    .navigationTitle("LocalDevices")
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  HomeView()
}
