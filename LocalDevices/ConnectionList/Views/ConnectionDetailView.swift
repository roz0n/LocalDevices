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
  @State private var isComposeSheetPresented: Bool = false
  @State private var selectedMessage: MessageViewModel? = nil
  
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
            .foregroundStyle(.cyan)
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
      
      Section("\(viewModel.messages.count) Messages Received") {
        if viewModel.messages.isEmpty {
          Text("Nothing yet...")
            .opacity(0.35)
        }
        
        ForEach(viewModel.messages.reversed()) { messageViewModel in
          Button {
            selectedMessage = messageViewModel
          } label: {
            HStack(alignment: .center) {
              Text(
                DateFormatter.localizedString(
                  from: messageViewModel.message.timestamp,
                  dateStyle: .short,
                  timeStyle: .long
                )
                .uppercased()
              )
              Spacer()
              Image(systemName: "chevron.right")
            }
            .font(.system(size: 12, weight: .medium, design: .monospaced))
          }
          
          Group {
            if let message = String(data: messageViewModel.message.data, encoding: .utf8) {
              Text(message)
            } else {
              Text("\(messageViewModel.message.data.bytes.count) Byte Message")
            }
          }
          .padding(.vertical, 2)
          .font(.system(size: 14, weight: .regular, design: .monospaced))
        }
      }
    }
    .navigationTitle(viewModel.name)
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
    .sheet(isPresented: $isComposeSheetPresented) {
      NavigationStack {
        composeMessageSheetContent
      }
      .scrollDisabled(true)
      .presentationDetents([.height(200)])
      .presentationBackgroundInteraction(.enabled(upThrough: .height(200)))
      .interactiveDismissDisabled()
    }
    .navigationDestination(item: $selectedMessage) { messageViewModel in
      MessageDetailView(viewModel: messageViewModel)
    }
    .onAppear {
      isComposeSheetPresented = viewModel.isConnectionReady
    }
    .onChange(of: viewModel.isConnectionReady) { oldValue, newValue in
      isComposeSheetPresented = newValue
    }
  }
}

extension ConnectionDetailView {
  
  private var composeMessageSheetContent: some View {
    Form {
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
            
            // FIXME: This will send the APG request
            
          } label: {
            Text("Send")
              .font(.system(size: 16, weight: .semibold))
          }
          .buttonBorderShape(.capsule)
          .buttonStyle(.bordered)
          .tint(.accent)
          .disabled(isSendButtonDisabled)
          
          Button {
            viewModel.sendData(apgRequestBuilder.createNonceRequest())
          } label: {
            Text("NRequest")
              .font(.system(size: 16, weight: .semibold))
          }
          .buttonBorderShape(.capsule)
          .buttonStyle(.bordered)
          .tint(.yellow)
        }
        .padding(.vertical, 4)
      }.listRowSeparator(.hidden)
    }
  }
  
}

#Preview {
  NavigationStack {
    ConnectionDetailView(viewModel: ConnectionViewModel(connection: .previewStub))
      .navigationBarTitleDisplayMode(.inline)
  }
}
