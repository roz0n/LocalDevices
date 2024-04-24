//
//  NetworkConnectionProvider.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Foundation
import Network

/// An object factory that conforms to ``NetworkConnectionBuilder``.
struct NetworkConnectionProvider: NetworkConnectionBuilder {
  
  var `protocol`: NWParameters
  
  func createConnection(host: NWEndpoint.Host, port: NWEndpoint.Port) -> NWConnection {
    NWConnection(host: host, port: port, using: `protocol`)
  }
  
  func createListener(port: NWEndpoint.Port, on queue: DispatchQueue = .global()) throws -> NWListener {
    do {
      let listener = try NWListener(using: `protocol`, on: port)
      
      listener.newConnectionHandler = {
        handleNewConnection($0, queue: queue)
      }
      
      return listener
    } catch {
      throw error
    }
  }
  
  func handleNewConnection(_ connection: NWConnection, queue: DispatchQueue) {
    connection.receiveMessage { content, contentContext, isComplete, error in
      guard error == nil else {
        print("Error handling new connection: \(error as Any)")
        return
      }
      
      if let content, let message = String(data: content, encoding: .utf8) {
        print("New connection content: \(message)")
      } else {
        print("New connection did not provide new message...")
      }
    }
    
    connection.start(queue: queue)
  }
  
}
