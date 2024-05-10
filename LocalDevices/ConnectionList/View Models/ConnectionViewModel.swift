//
//  ConnectionViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Combine
import Network

class ConnectionViewModel: ObservableObject, Identifiable {
  
  @Published var isConnectionReady: Bool = false
  @Published var isConnectionFailed: Bool = false
  
  private var connectionManager: NetworkConnectionManager
  private var cancellables: Set<AnyCancellable> = []
  
  private (set) var connection: Connection
  
  // MARK: - Computed Properties
  
  var name: String {
    connection.name
  }
  
  var port: String {
    "\(connection.port)"
  }
  
  var dnsProtocol: String {
    connection.dnsProtocol.rawValue
  }
  
  // MARK: - Lifecycle
  
  init(connection: Connection) {
    self.connection = connection
    self.connectionManager = NetworkConnectionManager(
      host: connection.host,
      port: connection.port,
      type: connection.protocolParameter
    )
    self.subscribeToConnectionState()
  }
  
  // MARK: - Networking
  
  func connect() {
    print("Connecting: \(name) @ \(port)")
    connectionManager.connect()
  }
  
  func cancel() {
    print("Disconnecting: \(name) @ \(port)")
    connectionManager.cancel()
  }
  
  func sendData(_ data: Data) {
    print("Sending data: \(data) to \(name) @ \(port)")
    connectionManager.send(message: data)
  }
  
  func subscribeToConnectionState() {
    self.connectionManager.connectionStatePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        guard let name = self?.name, let port = self?.port else {
          return
        }
        
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
  
}

let device = NetworkDevice(
  ipAddress: "192.168.0.13",
  macAddress: "70:B3:D5:BC:F8:D6",
  serialNumber: "429004699",
  productName: "APG Atwood",
  productBarcode: ""
)

let apgRequestBuilder = APGRequestBuilder(device: device)
