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
      Section {
        HStack(alignment: .center) {
          if !viewModel.isConnectionReady {
            Button {
              viewModel.connect()
            } label: {
              HStack(spacing: 8) {
                Image(systemName: "play.fill")
                Text("Connect")
                  .bold()
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .tint(.cyan)
          } else if viewModel.isConnectionReady {
            Button {
              viewModel.cancel()
            } label: {
              HStack(spacing: 8) {
                Image(systemName: "stop.fill")
                Text("Cancel")
                  .bold()
              }
              .padding(.vertical, 4)
              .padding(.horizontal, 8)
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .tint(.red)
          }
        }
      }
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets())
      
      Section("Host details") {
        LabeledContent {
          TextField("IP Address", text: $ipAddressText)
            .disabled(true)
            .monospaced()
        } label: {
          Image(systemName: "network")
            .foregroundStyle(.blue)
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
      
      if viewModel.isConnectionReady {
        Section("Messages log") {
          
        }
      }
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
