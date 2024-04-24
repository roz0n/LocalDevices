//
//  NetworkDeviceService.swift
//  GCExpressCheckout
//
//  Created by Arnaldo Rozon on 4/23/24.
//  Copyright © 2024 Guitar Center, Inc. All rights reserved.
//

import Foundation
import Network

/// A service that both initializes and runs a connection and listener for a given host, port, and provider conforming to ``NetworkConnectionBuilder``.
class NetworkDeviceService: NetworkConnectable {
  
  private (set) var connection: NWConnection?
  private (set) var listener: NWListener?
  private (set) var queue = DispatchQueue(label: "com.guitarcenter.expressmobile.networkdeviceservice")
  
  // MARK: - Lifecycle

  /// A failable initializer that
  init?(host: NWEndpoint.Host, port: NWEndpoint.Port, provider: NetworkConnectionBuilder) {
    do {
      self.connection = provider.createConnection(host: host, port: port)
      self.listener = try provider.createListener(port: port)
      
      try startConnection()
      try startListener()
    } catch {
      print("Error initializing NetworkDeviceService: \(error.localizedDescription)\n\(error)")
      return nil
    }
  }
  
  // MARK: - Connection
  
  private func startConnection() throws {
    guard let connection else {
      throw NetworkConnectionError.connectionFailure
    }
    
    connection.start(queue: queue)
  }
  
  private func startListener() throws {
    guard let listener else {
      throw NetworkConnectionError.listenerFailure
    }
    
    listener.start(queue: queue)
  }
  
}
