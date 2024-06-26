//
//  NetworkConnectionManager.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Network
import Combine

class NetworkConnectionManager {
  
  private var connection: NWConnection?
  
  let host: NWEndpoint.Host
  let port: NWEndpoint.Port
  let type: NWParameters
  let queue: DispatchQueue
  var onReceieveMessage: (((data: Data, date: Date)) -> Void)? = nil
  
  private (set) var connectionStatePublisher = PassthroughSubject<NWConnection.State, Never>()
  
  init(
    host: String,
    port: UInt16,
    type: NWParameters,
    on queue: DispatchQueue = .global(),
    onReceive: ((Data, Date) -> Void)? = nil
  ) {
    self.host = NWEndpoint.Host(host)
    self.port = NWEndpoint.Port(rawValue: port)!
    self.type = type
    self.queue = queue
  }
  
  func connect() {
    connection = NWConnection(host: host, port: port, using: type)
    
    connection?.stateUpdateHandler = { [weak self] state in
      self?.connectionStatePublisher.send(state)
    }
    
    connection?.start(queue: queue)
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
    connection?.receive(minimumIncompleteLength: 1, maximumLength: 65536) { [weak self] data, _, isComplete, error in
      if let data {
        self?.onReceieveMessage?((data, Date.now))
        
        if let message = String(data: data, encoding: .utf8) {
          print("Received message: \(message)")
        }
      }
      
      if isComplete {
        self?.connection?.cancel()
        print("Connection closed by the server.")
      } else if let error = error {
        print("Error receiving data: \(error)")
      }
    }
  }
  
  func cancel() {
    connection?.cancel()
  }
  
}
