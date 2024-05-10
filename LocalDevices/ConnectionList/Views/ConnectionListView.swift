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
  
  @StateObject private var listViewModel: ConnectionListViewModel = ConnectionListViewModel()
  
  @State private var isAddSheetPresented: Bool = false
  @State private var isActionMenuPresented: Bool = false
  
  // MARK: - Body
  
  var body: some View {
    List {
      Section {
        ForEach(listViewModel.connections) { connectionViewModel in
          ConnectionCellView(viewModel: connectionViewModel)
            .onTapGesture {
              isActionMenuPresented = true
              print("Selected: \(connectionViewModel.id)")
            }
        }
      } header: {
        if !listViewModel.connections.isEmpty {
          Text("listViewModel.connections")
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
      ConnectionListFormView { newConnection in
        listViewModel.connections.append(newConnection)
      }
    }
    .confirmationDialog("Some Title Here",
                        isPresented: $isActionMenuPresented,
                        presenting: $listViewModel.selectedConnection) { _ in
      Button {
        listViewModel.selectedConnection?.connect()
      } label: {
        Text("Initialize Connection")
      }
    }
  }
  
}

extension ConnectionListView {
  
  @ViewBuilder
  private var overlayContent: some View {
    if listViewModel.connections.isEmpty {
      ContentUnavailableView("No Connections",
                             systemImage: "circle.dotted.and.circle",
                             description: Text("Connections you make will appear here"))
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
  
}

#Preview {
  ConnectionListView()
}
