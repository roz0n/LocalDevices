//
//  NetworkConnectionManager.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Network
import Combine

/// Handles a single UDP network connection listener.
class NetworkConnectionManager {
  
  private (set) var listener: NWListener?
  private (set) var connection: NWConnection?
  
  let host: NWEndpoint.Host
  let port: NWEndpoint.Port
  let type: NWParameters
  let queue: DispatchQueue
  var onReceieveMessage: (((data: Data, date: Date)) -> Void)? = nil
  
  private (set) var isListening = CurrentValueSubject<Bool, Never>(false)
  private (set) var listenerState = PassthroughSubject<NWListener.State, Never>()
  private (set) var connectionState = PassthroughSubject<NWConnection.State, Never>()
  
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
    listen()
  }
  
  func listen() {
    do {
      listener = try NWListener(using: type, on: port)
      
      listener?.stateUpdateHandler = { [weak self] state in
        guard let self else {
          return
        }
        
        switch state {
          case .ready:
            DispatchQueue.main.async {
              self.isListening.send(true)
            }
            
            print("Listener ready on port: \(self.port as Any)")
          case .failed, .cancelled:
            DispatchQueue.main.async {
              self.isListening.send(false)
            }
            
            print("Listener disconnected from port: \(self.port as Any)")
          default:
            print("Listener connecting to port: \(self.port as Any)")
        }
        
        self.listenerState.send(state)
      }
      
      listener?.newConnectionHandler = {  [weak self] incomingConnection in
        self?.createConnection(incomingConnection)
      }
      
      listener?.start(queue: queue)
    } catch {
      print("Listener error: \(error)")
    }
  }
  
  func send(message: Data) {
    if connection == nil {
      let newConnection = NWConnection(host: host, port: port, using: type)
      createConnection(newConnection)
    }
    
    connection?.send(content: message, completion: .contentProcessed({ error in
      if let error = error {
        print("Failed to send data: \(error)")
        return
      }
      
      print("Data sent")
      
      if let connection = self.connection {
        // Receive after sending in case we expect a response
        self.receive(on: connection)
      }
    }))
  }
  
  func createConnection(_ connection: NWConnection) {
    self.connection = connection
    
    connection.stateUpdateHandler = { state in
      switch state {
        case .ready:
          print("Connection ready to receive data")
          self.receive(on: connection)
        case .failed, .cancelled:
          self.isListening.send(false)
          connection.cancel()
        default:
          break
      }
      
      self.connectionState.send(state)
    }
    
    self.connection?.start(queue: queue)
  }
  
  func receive(on connection: NWConnection) {
    connection.receiveMessage { [weak self] data, contentContext, isComplete, error in
      guard let self else {
        return
      }
      
      if let error {
        print("Receive error: \(error)")
        return
      }
      
      if let data {
        print("Listener Received data: \(data)")
        
        if let string = String(data: data, encoding: .utf8) {
          print("Data as string: \(string)")
        }
        
        self.onReceieveMessage?((data, Date.now))
        
        if self.isListening.value {
          // Recursive call to continue receiving
          self.receive(on: connection)
        }
      }
    }
  }
  
  func cancel() {
    listener?.stateUpdateHandler = nil
    listener?.newConnectionHandler = nil
    listener?.cancel()
    
    connection?.stateUpdateHandler = nil
    connection?.cancel()
    
    isListening.send(false)
  }
  
}
