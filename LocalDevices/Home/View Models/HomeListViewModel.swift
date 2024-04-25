//
//  NetworkDeviceListViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation
import Combine

// TODO: Right now this is creating a UDP connection and consuming the announce packet of the device listening for connections on that port, in this case the APG Atwood (page 6)
// [] We'll need to spawn two connections, UDP for discovery and TCP for sending the actual commands
// [] Once we recieve an announce packet of the APG Atwood and store its contents, we'll know where to find the device. We need to open a TCP socket to the drawer and perform the TCP nonce exchange (page 11)
// [] Once we get the TCP nonce request response, we need to send a TLSChangeCommand (page 12) (page 22)

class NetworkDeviceListViewModel: ObservableObject {
  
  @Published var devices: [LocalNetworkDeviceViewModel]
  
  private var service: NetworkDeviceService?
  private var cancellables: Set<AnyCancellable> = []
  
  init(devices: [LocalNetworkDeviceViewModel] = []) {
    self.devices = devices
    self.service = NetworkDeviceService(
      host: .ipv4(.broadcast),
      port: 10004,
      provider: NetworkConnectionProvider(protocol: .udp)
    )
    
    subscribeToDevices()
  }
  
  private func subscribeToDevices() {
    service?.deviceDiscoveryPublisher
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] device in
        self?.devices.append(.init(device: device))
      })
      .store(in: &cancellables)
  }
  
}
