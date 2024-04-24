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
  
  func createListener(port: NWEndpoint.Port) throws -> NWListener {
    do {
      let listener = try NWListener(using: `protocol`, on: port)
      // TODO: Handler implementation
      return listener
    } catch {
      throw error
    }
  }
  
}
