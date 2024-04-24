//
//  NetworkDeviceService.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Foundation
import Combine
import Network

/// A service that both initializes and runs a connection and listener for a given host, port, and provider conforming to ``NetworkConnectionBuilder``.
class NetworkDeviceService: NetworkConnectable {
  
  private (set) var connection: NWConnection?
  private (set) var listener: NWListener?
  private (set) var queue: DispatchQueue
  private (set) var deviceDiscoveryPublisher = PassthroughSubject<String, Never>()
  
  // MARK: - Lifecycle
  
  /// A failable initializer that
  init?(host: NWEndpoint.Host,
        port: NWEndpoint.Port,
        queue: DispatchQueue = .global(),
        provider: NetworkConnectionBuilder) {
    do {
      self.connection = provider.createConnection(host: host, port: port)
      self.listener = try provider.createListener(port: port, on: queue)
      self.queue = queue
      
      try startConnection()
      try startListener()
      
      print("NetworkDeviceService init success!")
    } catch {
      print("Error initializing NetworkDeviceService: \(error.localizedDescription)\n\(error)")
      return nil
    }
  }
  
  deinit {
    connection?.cancel()
    listener?.cancel()
  }
  
  // MARK: - Connection
  
  func startConnection() throws {
    guard let connection else {
      throw NetworkConnectionError.connectionFailure
    }
    
    connection.start(queue: queue)
  }
  
  func startListener() throws {
    guard let listener else {
      throw NetworkConnectionError.listenerFailure
    }
    
    listener.newConnectionHandler = { [weak self] in
      if let queue = self?.queue {
        self?.handleNewConnection($0, on: queue)
      }
    }
    
    listener.start(queue: queue)
  }
  
  func handleNewConnection(_ connection: NWConnection, on queue: DispatchQueue) {
    connection.receiveMessage { [weak self] content, contentContext, isComplete, error in
      guard error == nil else {
        print("Error handling new connection: \(error as Any)")
        return
      }
      
      if isComplete, let content, let message = String(data: content, encoding: .utf8) {
        print("New connection content: \(message)")
        
        self?.deviceDiscoveryPublisher.send(message)
      } else {
        print("New connection did not provide new message...")
      }
    }
    
    connection.start(queue: queue)
  }
  
}
