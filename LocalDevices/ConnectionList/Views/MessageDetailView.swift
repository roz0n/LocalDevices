//
//  MessageDetailView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/12/24.
//

import SwiftUI

struct MessageDetailView: View {
  
  var viewModel: MessageViewModel
  
  var body: some View {
    List {
      if let string = String(data: viewModel.message.data, encoding: .utf8) {
        Section("UTF-8 Representation") {
          Text(string)
            .font(.system(size: 14, weight: .regular, design: .monospaced))
            .padding(.vertical, 8)
        }
      }
      Section("Byte Representation") {
        Text(String(describing: viewModel.message.data.bytes))
          .font(.system(size: 14, weight: .regular, design: .monospaced))
      }
    }
    .navigationTitle(viewModel.message.timestamp.ISO8601Format(.iso8601))
    .navigationBarTitleDisplayMode(.inline)
  }
}

#Preview {
  let message = Message(data: "The world is yours.".data(using: .ascii)!, timestamp: Date.now)
  return (
    NavigationStack {
      MessageDetailView(viewModel: MessageViewModel(message: message))
    }
  )
}
