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
  @State private var messageText: String = ""
  
  init(viewModel: ConnectionViewModel) {
    self.viewModel = viewModel
    self.ipAddressText = viewModel.ipAddress
    self.portText = viewModel.port
  }
  
  private var isSendButtonDisabled: Bool {
    messageText.isEmpty
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
            .tint(.blue)
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
          Image(systemName: "rectangle.connected.to.line.below")
            .foregroundStyle(Color.orange)
        }
      }
      
      if viewModel.isConnectionReady {
        Section("Compose message") {
          TextField("Enter a message to send", text: $messageText, axis: .vertical)
            .lineLimit(3, reservesSpace: true)
            .padding(.top, 6)
            .autocorrectionDisabled()
          HStack(alignment: .center) {
            HStack(alignment: .center) {
              Image(systemName: "network")
              Text("192.168.0.1")
            }
            .font(.system(size: 12, weight: .regular, design: .monospaced))
            .opacity(0.5)
            
            Spacer()
            
            Button {
              if let data = messageText.data(using: .utf8) {
                viewModel.sendData(data)
                messageText = ""
              }
            } label: {
              Text("Send")
                .font(.system(size: 16, weight: .semibold))
            }
            .buttonBorderShape(.capsule)
            .buttonStyle(.bordered)
            .tint(.accent)
            .disabled(isSendButtonDisabled)
          }
          .padding(.vertical, 4)
        }.listRowSeparator(.hidden)
      }
      
      Section("Message log") {
        if viewModel.messages.isEmpty {
          Text("Nothing yet...")
            .opacity(0.35)
        } else {
          ForEach(viewModel.messages.reversed()) { messageViewModel in
            VStack {
              if let message = String(data: messageViewModel.message.data, encoding: .utf8) {
                Text(message)
              }
              
              Text(String(String(describing: messageViewModel.message.data.bytes)))
              Text(messageViewModel.message.timestamp.ISO8601Format())
            }
          }
        }
      }
    }
    .navigationTitle("\(viewModel.name) (\(viewModel.dnsProtocol.uppercased()))")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        if viewModel.isConnectionReady {
          ProgressView()
            .controlSize(.regular)
            .tint(.purple)
        }
      }
    }
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
