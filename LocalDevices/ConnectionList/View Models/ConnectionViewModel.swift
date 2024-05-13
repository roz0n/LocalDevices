//
//  ConnectionViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Combine
import Network

@MainActor
final class ConnectionViewModel: ObservableObject, Identifiable {
  
  @Published var isConnectionReady: Bool = false
  @Published var currentError: NWError? = nil
  @Published var isErrorAlertPresented: Bool = false
  
  /// Messages logged ephemerally in memory.
  @Published var messages: [MessageViewModel] = []
  
  /// An abstraction over NW that handles an individual network connection.
  private var connectionManager: NetworkConnectionManager
  private var cancellables: Set<AnyCancellable> = []
  
  /// A connection model for storage purposes.
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
  
  init(connection: Connection, on queue: DispatchQueue = .global()) {
    self.connection = connection
    self.connectionManager = NetworkConnectionManager(
      host: connection.host,
      port: connection.port,
      type: connection.protocolParameter,
      on: queue
    )
    self.subscribeToConnectionState()
    self.setup()
  }
  
  deinit {
    connectionManager.cancel()
  }
  
  private func setup() {
    connectionManager.onReceieveMessage = { [weak self] message in
      DispatchQueue.main.async {
        self?.handleMessageResponse(message.data, timestamp: message.date)
      }
    }
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
    connectionManager.send(message: data)
    print("⬆️ Sent data via \(type.rawValue.uppercased()): \(data) to \(name) @ \(port)")
  }
  
  func subscribeToConnectionState() {
    self.connectionManager.isListening
      .receive(on: DispatchQueue.main)
      .sink { [weak self] isListening in
        guard let self else {
          return
        }
        
        self.resetError()
        isConnectionReady = isListening
      }.store(in: &cancellables)
  }
  
  func handleMessageResponse(_ data: Data, timestamp: Date) {
    let newMessage = Message(data: data, timestamp: timestamp)
    messages.append(MessageViewModel(message: newMessage))
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
