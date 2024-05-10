//
//  ConnectionViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Combine
import Network

let device = LocalNetworkDevice(
  ipAddress: "192.168.0.13",
  macAddress: "70:B3:D5:BC:F8:D6",
  serialNumber: "429004699",
  productName: "APG Atwood",
  productBarcode: ""
)

let apgRequestBuilder = APGRequestBuilder(device: device)

class ConnectionViewModel: ObservableObject, Identifiable {
    
  @Published var isConnectionReady: Bool = false
  @Published var isConnectionFailed: Bool = false
  
  private var connectionManager: NetworkConnectionManager
  private var cancellables: Set<AnyCancellable> = []
  
  var name: String
  
  var port: String {
    "\(Int(connectionManager.port.rawValue))"
  }
  
  var id: String {
    "\(name)-\(self.port)"
  }
  
  init(name: String, host: String, port: UInt16, type: NWParameters) {
    self.name = name
    self.connectionManager = NetworkConnectionManager(host: host, port: port, type: type)
    
    self.connectionManager.connectionStatePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        switch state {
          case .setup:
            print("🔌 Setting up connection: \(name) @ \(port)")
          case .waiting(let nWError):
            print("🔌 Setting up connection: \(name) @ \(port). Error: \(nWError.localizedDescription)")
          case .preparing:
            print("🔌 Preparing connection: \(name) @ \(port)")
          case .ready:
            print("🔌 Connection: \(name) @ \(port) is READY.")
            self?.isConnectionReady = true
          case .failed(let nWError):
            print("🔌 Connection: \(name) @ \(port) FAILED! Error: \(nWError.localizedDescription)")
            self?.isConnectionReady = false
          case .cancelled:
            print("🔌 Connection: \(name) @ \(port) was CANCELLED!")
            self?.isConnectionReady = false
          @unknown default:
            self?.isConnectionReady = false
            fatalError("Unable to connect")
        }
      }.store(in: &cancellables)
  }
  
  func connect() {
    print("Connecting: \(name)")
    connectionManager.connect()
  }
  
  func sendData(_ data: Data) {
    connectionManager.send(message: data)
  }
  
}
