//
//  ConnectionDetailView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import SwiftUI

struct ConnectionDetailView: View {
  
  @ObservedObject var viewModel: ConnectionViewModel
  
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
        HStack(alignment: .center) {
          Spacer()
          if !viewModel.isConnectionReady {
            Button {
              viewModel.connect()
            } label: {
              HStack(spacing: 8) {
                Image(systemName: "powercord.fill")
                Text("Connect")
                  .bold()
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .tint(.green)
          } else if viewModel.isConnectionReady {
            Button {
              viewModel.cancel()
            } label: {
              Text("Cancel")
                .font(.system(size: 16, weight: .semibold, design: .default))
                .padding(.vertical, 4)
                .padding(.horizontal, 8)
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .tint(.red)
          }
          Spacer()
        }
      }.listRowBackground(Color.clear)
    }
    .navigationTitle("\(viewModel.name) (\(viewModel.dnsProtocol.uppercased()))")
    .alert(isPresented: $viewModel.isErrorAlertPresented) {
      Alert(title: Text("Connection Failed"),
            message: Text(viewModel.currentError?.localizedDescription ?? "No description available"))
    }
  }
}

#Preview {
  NavigationStack {
    ConnectionDetailView(viewModel: ConnectionViewModel(connection: .previewStub))
      .navigationBarTitleDisplayMode(.inline)
  }
}
