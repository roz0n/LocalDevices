//
//  HomeView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import SwiftUI
import Combine
import Network

enum LocalNetworkProtocol: String {
  case tcp
  case udp
}

struct HomeView: View {
  
  @State private var isAddSheetPresented: Bool = false
  @State private var newConnectionSelectedProtocol: LocalNetworkProtocol = .tcp
  @State private var newConnectionPortText: String = ""
  @State private var newConnectionHostAddress: String = ""
  
  @State private var connections: [TCPViewModel] = []
  
  private func resetForm() {
    newConnectionSelectedProtocol = .tcp
    newConnectionPortText = ""
    newConnectionHostAddress = ""
  }
  
  private var isFormDisabled: Bool {
    newConnectionPortText.isEmpty || newConnectionHostAddress.isEmpty
  }
  
  private var selectedProtocol: NWParameters {
    newConnectionSelectedProtocol == .tcp ? NWParameters.tcp : NWParameters.udp
  }
  
  private var selectedPort: UInt16 {
    UInt16(Int(newConnectionPortText) ?? 0)
  }
  
  var body: some View {
    List {
      ForEach(connections) { connectionViewModel in
        VStack(alignment: .leading, spacing: 8) {
          Text(connectionViewModel.name)
          Text(connectionViewModel.port)
        }
      }
    }
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button {
          isAddSheetPresented = true
        } label: {
          Image(systemName: "plus.circle")
        }
        .tint(.mint)
      }
    }
    .navigationTitle("LocalDevices")
    .navigationBarTitleDisplayMode(.inline)
    .sheet(isPresented: $isAddSheetPresented) {
      NavigationStack {
        Form {
          Section("Connection Type") {
            Picker("Protocol", selection: $newConnectionSelectedProtocol) {
              Text("TCP")
                .tag(LocalNetworkProtocol.tcp)
              Text("UDP")
                .tag(LocalNetworkProtocol.udp)
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
                let newConnection = TCPViewModel(host: newConnectionPortText,
                                                 port: selectedPort,
                                                 type: selectedProtocol)
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
      }
      .presentationDragIndicator(.visible)
    }
  }
}

#Preview {
  HomeView()
}
