//
//  HomeListViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 4/24/24.
//

import Foundation
import Combine

class HomeListViewModel: ObservableObject {
  
  @Published var devices: [String]
  
  private var service: NetworkDeviceService?
  private var cancellables: Set<AnyCancellable> = []
  
  init(devices: [String] = []) {
    self.devices = devices
    self.service = NetworkDeviceService(
      host: .ipv4(.broadcast),
      port: 10004,
      provider: NetworkConnectionProvider(protocol: .udp)
    )
    
    subscribeToDevices()
  }
  
  private func subscribeToDevices() {
    self.service?.devices
      .receive(on: DispatchQueue.main)
      .sink(receiveValue: { [weak self] string in
        self?.devices.append(string)
      })
      .store(in: &cancellables)
  }
  
}
