//
//  ConnectionListFormView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import SwiftUI
import Network

struct ConnectionListFormView: View {
  
  @State var newConnectionSelectedProtocol: ConnectionProtocolIdentifier = .tcp
  @State var newConnectionNameText: String = ""
  @State var newConnectionPortText: String = ""
  @State var newConnectionHostAddress: String = ""
  
  var onSubmit: ((ConnectionViewModel) -> Void)?
  
  private var isFormDisabled: Bool {
    newConnectionNameText.isEmpty ||
    newConnectionPortText.isEmpty ||
    newConnectionHostAddress.isEmpty ||
    selectedPort == nil
  }
  
  var selectedProtocol: NWParameters {
    newConnectionSelectedProtocol == .tcp ? NWParameters.tcp : NWParameters.udp
  }
  
  var selectedPort: UInt16? {
    UInt16(newConnectionPortText)
  }
  
  private func resetForm() {
    newConnectionSelectedProtocol = .tcp
    newConnectionNameText = ""
    newConnectionPortText = ""
    newConnectionHostAddress = ""
  }
  
  private func handleSubmit() {
    let newConnection = Connection(name: newConnectionNameText,
                                   host: newConnectionPortText,
                                   port: selectedPort ?? 0,
                                   type: selectedProtocol)
    let viewModel = ConnectionViewModel(connection: newConnection)
    
    onSubmit?(viewModel)
    resetForm()
  }
  
  var body: some View {
    NavigationStack {
      Form {
        Section("Connection Details") {
          TextField("Name", text: $newConnectionNameText)
          
          Picker("Protocol", selection: $newConnectionSelectedProtocol) {
            Text("TCP")
              .tag(ConnectionProtocolIdentifier.tcp)
            Text("UDP")
              .tag(ConnectionProtocolIdentifier.udp)
          }
        }
        
        Section("Host Configuration") {
          LabeledContent {
            TextField("IP Address", text: $newConnectionHostAddress)
          } label: {
            Image(systemName: "network")
              .foregroundStyle(Color.purple)
          }
          
          LabeledContent {
            TextField("Port", text: $newConnectionPortText)
          } label: {
            Image(systemName: "app.connected.to.app.below.fill")
              .foregroundStyle(Color.orange)
          }
        }
        
        Section {
          HStack(alignment: .center) {
            Spacer()
            Button {
              handleSubmit()
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
            .tint(.mint)
            .disabled(isFormDisabled)
            Spacer()
          }
        }
        .listRowBackground(Color.clear)
      }
      .navigationTitle("New Connection")
      .navigationBarTitleDisplayMode(.inline)
      .tint(.mint)
    }
    .presentationDragIndicator(.visible)
  }
}

#Preview {
  ConnectionListFormView()
}
