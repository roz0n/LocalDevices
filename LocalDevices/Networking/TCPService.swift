//
//  LocalNetworkConnectionManager.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Network
import Combine

class LocalNetworkConnectionManager {
  
  private var connection: NWConnection?
  
  let host: NWEndpoint.Host
  let port: NWEndpoint.Port
  let type: NWParameters
  
  private (set) var connectionStatePublisher = PassthroughSubject<NWConnection.State, Never>()
  
  init(host: String, port: UInt16, type: NWParameters) {
    self.host = NWEndpoint.Host(host)
    self.port = NWEndpoint.Port(rawValue: port)!
    self.type = type
  }
  
  func connect() {
    connection = NWConnection(host: host, port: port, using: type)
    
    connection?.stateUpdateHandler = { [weak self] state in
      self?.connectionStatePublisher.send(state)
    }
    
    connection?.start(queue: .global())
  }
  
  func send(message: Data) {
    connection?.send(content: message, completion: .contentProcessed({ error in
      if let error = error {
        print("Failed to send data: \(error)")
        return
      }
      
      print("Data sent")
      self.receive()
    }))
  }
  
  func receive() {
    connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { data, _, isComplete, error in
      if let data = data, let message = String(data: data, encoding: .utf8) {
        print("Received message: \(message)")
      }
      
      if isComplete {
        self.connection?.cancel()
        print("Connection closed by the server.")
      } else if let error = error {
        print("Error receiving data: \(error)")
      }
    }
  }
  
}
