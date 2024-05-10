//
//  ConnectionListViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import Foundation
import Network

final class ConnectionListViewModel: ObservableObject {
  
  @Published var connections: [ConnectionViewModel] = []
  @Published var selectedConnection: ConnectionViewModel? = nil
  
  // MARK: - Computeds
  
  var all: [Connection] {
    connections.map { $0.connection }
  }
  
  // MARK: - Helpers
  
  func populateConnections() {
    // Go into user defaults and load the list of connections
  }
  
}
