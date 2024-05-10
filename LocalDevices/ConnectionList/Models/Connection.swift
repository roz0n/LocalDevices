//
//  Connection.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import Network

struct Connection: Codable {
  
  var name: String
  var host: String
  var port: UInt16
  var dnsProtocol: ConnectionProtocol
  
  var protocolParameter: NWParameters {
    switch dnsProtocol {
      case .tcp:
          .tcp
      case .udp:
          .udp
    }
  }
  
  enum ConnectionProtocol: String, Codable {
    case tcp
    case udp
  }
  
  enum CodingKeys: CodingKey {
    case name
    case host
    case port
    case dnsProtocol
  }
  
}

extension Connection {
  
  static var previewStub = Connection(name: "Test Connection",
                                      host: "192.168.0.6",
                                      port: 12345,
                                      dnsProtocol: .udp)
  
}
