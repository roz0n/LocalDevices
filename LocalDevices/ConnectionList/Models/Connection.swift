//
//  Connection.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import Network

struct Connection {
  var name: String
  var host: String
  var port: UInt16
  var type: NWParameters
}

extension Connection {
  
  static var previewStub = Connection(name: "Test Connection",
                               host: "192.168.0.6",
                               port: 12345,
                               type: .udp)
  
}
