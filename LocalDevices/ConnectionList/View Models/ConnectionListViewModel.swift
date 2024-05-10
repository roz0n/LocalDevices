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
  @Published var isLoading: Bool = false
  @Published var hasLoaded: Bool = false
  
  static var userDefaultsKey: String = "connectionList"
  
  // MARK: - Computeds
  
  var allConnections: [Connection] {
    connections.map { $0.connection }
  }
  
  // MARK: - Helpers
  
  /// Adds a new connection to the connections list.
  func add(_ connection: ConnectionViewModel) {
    do {
      isLoading = true
      
      defer {
        isLoading = false
      }
      
      var updatedConnections = connections
      updatedConnections.append(connection)
      
      let updatedList = updatedConnections.map { $0.connection }
      
      try UserDefaultsManager.shared.set(ConnectionListViewModel.userDefaultsKey, updatedList) { [weak self] newConnection in
        guard let newConnection else {
          print("Error add new command did not return new connection!")
          return
        }
        
        print("Created new connection: \(newConnection)")
        self?.connections = updatedConnections
      }
    } catch {
      print("Error - Unable to fetch user defaults list: \(error)")
    }
  }
  
  /// Loads all connections from user defaults and sets them to the `connections` property.
  func load() {
    // FIXME: - Add better error handling
    
    do {
      isLoading = true
      
      defer {
        isLoading = false
      }
      
      guard let data: [Connection]? = try UserDefaultsManager.shared.get(ConnectionListViewModel.userDefaultsKey), let data else {
        return
      }
      
      connections = data.compactMap { .init(connection: $0) }
      print("Loaded connections: \(data as Any)")
    } catch {
      print("Error unable to fetch conneciton list: \(error)")
    }
  }
  
  /// Removes a connection from the list.
  func delete(at offsets: IndexSet) {
    
  }
  
}
