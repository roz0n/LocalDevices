//
//  ConnectionDetailView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import SwiftUI

struct ConnectionDetailView: View {
  
  var viewModel: ConnectionViewModel
  
  @State private var ipAddressText: String
  @State private var portText: String
  
  init(viewModel: ConnectionViewModel) {
    self.viewModel = viewModel
    self.ipAddressText = viewModel.ipAddress
    self.portText = viewModel.port
  }
  
  var body: some View {
    List {
      Section("Host details") {
        LabeledContent {
          TextField("IP Address", text: $ipAddressText)
            .disabled(true)
            .monospaced()
        } label: {
          Image(systemName: "network")
            .foregroundStyle(Color.purple)
        }
        
        LabeledContent {
          TextField("Port", text: $portText)
            .disabled(true)
            .monospaced()
        } label: {
          Image(systemName: "app.connected.to.app.below.fill")
            .foregroundStyle(Color.orange)
        }
      }
      
      Section {
        // We'll ad a button to send a UDP message here
      }
    }
    .navigationTitle("\(viewModel.name) (\(viewModel.dnsProtocol.uppercased()))")
  }
}

#Preview {
  NavigationStack {
    ConnectionDetailView(viewModel: ConnectionViewModel(connection: .previewStub))
      .navigationBarTitleDisplayMode(.inline)
  }
}
