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
  @Published var currentError: NWError? = nil
  @Published var isErrorAlertPresented: Bool = false
  
  private var connectionManager: NetworkConnectionManager
  private var cancellables: Set<AnyCancellable> = []
  private (set) var connection: Connection
  
  // MARK: - Computed Properties
  
  var name: String {
    connection.name
  }
  
  var ipAddress: String {
    connection.host
  }
  
  var port: String {
    "\(connection.port)"
  }
  
  var dnsProtocol: String {
    connection.dnsProtocol.rawValue
  }
  
  var type: Connection.ConnectionProtocol {
    connection.dnsProtocol
  }
  
  private var isConnectionFailed: Bool {
    currentError != nil || isErrorAlertPresented
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
  
  deinit {
    connectionManager.cancel()
  }
  
  // MARK: - Networking
  
  func connect() {
    print("\n🆕 Creating new \(type.rawValue.uppercased()) connection: \(name) @ \(port)")
    connectionManager.connect()
  }
  
  func cancel() {
    print("✴️ Disconnecting \(type.rawValue.uppercased()) connection: \(name) @ \(port)")
    connectionManager.cancel()
  }
  
  func sendData(_ data: Data) {
    print("⬆️ Sending data via \(type.rawValue.uppercased()): \(data) to \(name) @ \(port)")
    connectionManager.send(message: data)
  }
  
  func subscribeToConnectionState() {
    self.connectionManager.connectionStatePublisher
      .receive(on: DispatchQueue.main)
      .sink { [weak self] state in
        guard let name = self?.name, let port = self?.port else {
          return
        }
        
        self?.resetError()
        
        switch state {
          case .setup:
            print("ℹ️ Initializing \(self?.type.rawValue.uppercased() ?? "?") connection: \(name) @ \(port)")
          case .waiting(let nWError):
            print("🆘 Waiting to set up \(self?.type.rawValue.uppercased() ?? "?") connection: \(name) @ \(port): \(nWError.localizedDescription)")
            self?.setError(nWError)
          case .preparing:
            print("🅿️ Preparing \(self?.type.rawValue.uppercased() ?? "?") connection: \(name) @ \(port)")
          case .ready:
            print("✅ \(self?.type.rawValue.uppercased() ?? "?") Connection: \(name) @ \(port) is READY to send and receive data")
            self?.isConnectionReady = true
          case .failed(let nWError):
            print("🈲 \(self?.type.rawValue.uppercased() ?? "?") Connection: \(name) @ \(port) has disconnected or encountered an error: \(nWError.localizedDescription)")
            self?.setError(nWError)
          case .cancelled:
            print("☑️ \(self?.type.rawValue.uppercased() ?? "?") Connection: \(name) @ \(port) was CANCELLED!\n")
            self?.isConnectionReady = false
          @unknown default:
            self?.isConnectionReady = false
            fatalError("🆘 \(self?.type.rawValue.uppercased() ?? "?") Connection: \(name) @ \(port) returned an unknown state.")
        }
      }.store(in: &cancellables)
  }
  
  func setError(_ error: NWError) {
    currentError = error
    isErrorAlertPresented = true
    isConnectionReady = false
  }
  
  func resetError() {
    currentError = nil
    isErrorAlertPresented = false
    isConnectionReady = false
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
