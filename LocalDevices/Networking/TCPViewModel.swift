//
//  TCPViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/9/24.
//

import Foundation
import Combine
import Network

//let device = LocalNetworkDevice(
//  ipAddress: "192.168.0.13",
//  macAddress: "70:B3:D5:BC:F8:D6",
//  serialNumber: "429004699",
//  productName: "APG Atwood",
//  productBarcode: ""
//)
//
//let apgRequestBuilder = APGRequestBuilder(device: device)

class TCPViewModel: ObservableObject, Identifiable {
  
//  @Published var connectionState: NWConnection.State? = nil
  
  private var connectionManager: LocalNetworkConnectionManager
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
    self.connectionManager = LocalNetworkConnectionManager(host: host, port: port, type: type)
    
    //    self.connectionManager.connectionStatePublisher
    //      .receive(on: DispatchQueue.main)
    //      .sink { [weak self] state in
    //        if state == .ready {
    //          self?.connectionState = state
    //        }
    //      }.store(in: &cancellables)
  }
  
  func connect() {
    connectionManager.connect()
  }
  
  func sendData(_ data: Data) {
    connectionManager.send(message: data)
  }
  
}
