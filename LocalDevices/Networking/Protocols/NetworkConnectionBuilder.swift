//
//  NetworkConnectionBuilder.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/23/24.
//

import Network

/// Represents entities that create `NWConnection` and `NWListener` objects based on a given host, port, and network protocol.
protocol NetworkConnectionBuilder {
  func createConnection(host: NWEndpoint.Host, port: NWEndpoint.Port) -> NWConnection
  func createListener(port: NWEndpoint.Port) throws -> NWListener
}
