//
//  ConnectionListView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import SwiftUI
import Combine
import Network

enum ConnectionProtocolIdentifier: String {
  case tcp
  case udp
}

struct ConnectionListView: View {
  
  @State private var newConnectionSelectedProtocol: ConnectionProtocolIdentifier = .tcp
  @State private var newConnectionNameText: String = ""
  @State private var newConnectionPortText: String = ""
  @State private var newConnectionHostAddress: String = ""
  
  @State private var connections: [ConnectionViewModel] = []
  @State private var selectedConnection: ConnectionViewModel? = nil
  
  @State private var isAddSheetPresented: Bool = false
  @State private var isActionMenuPresented: Bool = false
  
  private func resetForm() {
    newConnectionSelectedProtocol = .tcp
    newConnectionNameText = ""
    newConnectionPortText = ""
    newConnectionHostAddress = ""
  }
  
  private var isFormDisabled: Bool {
    newConnectionNameText.isEmpty || newConnectionPortText.isEmpty || newConnectionHostAddress.isEmpty
  }
  
  private var selectedProtocol: NWParameters {
    newConnectionSelectedProtocol == .tcp ? NWParameters.tcp : NWParameters.udp
  }
  
  private var selectedPort: UInt16? {
    UInt16(newConnectionPortText)
  }
  
  var body: some View {
    List {
      Section {
        ForEach(connections) { connectionViewModel in
          NetworkConnectionCell(viewModel: connectionViewModel)
            .onTapGesture {
              isActionMenuPresented = true
              print("Selected: \(connectionViewModel.id)")
            }
        }
      } header: {
        if !connections.isEmpty {
          Text("Connections")
        }
      }
    }
    .overlay {
      overlayContent
    }
    .toolbar {
      toolbarContent
    }
    .navigationTitle("Networker")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isAddSheetPresented) {
      sheetContent
    }
    .confirmationDialog("Some Title Here",
                        isPresented: $isActionMenuPresented,
                        presenting: $selectedConnection) { _ in
      Button {
        selectedConnection?.connect()
      } label: {
        Text("Initialize Connection")
      }
    }
  }
  
}

// MARK: - View Content

extension ConnectionListView {
  
  @ViewBuilder
  private var overlayContent: some View {
    if connections.isEmpty {
      ContentUnavailableView("No Connections",
                             systemImage: "circle.dotted.and.circle",
                             description: Text("Connections you add will appear here"))
    } else {
      EmptyView()
    }
  }
  
  @ToolbarContentBuilder
  private var toolbarContent: some ToolbarContent {
    ToolbarItem(placement: .topBarTrailing) {
      Button {
        isAddSheetPresented = true
      } label: {
        Image(systemName: "plus.circle")
      }
      .tint(.mint)
    }
  }
  
  private var sheetContent: some View {
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
              let newConnection = ConnectionViewModel(name: newConnectionNameText,
                                               host: newConnectionPortText,
                                               port: selectedPort ?? 0,
                                               type: selectedProtocol)
              // FIXME: Instead of appending, save this to user defaults
              connections.append(newConnection)
              isAddSheetPresented = false
              resetForm()
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

struct NetworkConnectionCell: View {
  
  var viewModel: ConnectionViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(viewModel.name)
        .bold()
      Text(viewModel.port)
        .monospaced()
    }
  }
  
}

#Preview {
  ConnectionListView()
}
