//
//  LocalDeviceCellView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import SwiftUI

struct LocalDeviceCellView: View {
  
  var viewModel: LocalNetworkDeviceViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 4) {
      Text(viewModel.name)
        .bold()
      
      VStack(alignment: .leading, spacing: 4) {
        Group {
          Text(viewModel.ipAddress)
          Text(viewModel.macAddress)
        }
        .opacity(0.5)
        .monospaced()
      }
    }
  }
}

//#Preview {
//  LocalDeviceCellView()
//}
