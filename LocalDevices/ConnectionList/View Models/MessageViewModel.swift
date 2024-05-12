//
//  MessageViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/11/24.
//

import Foundation

final class MessageViewModel: ObservableObject, Identifiable {
  
  private (set) var message: Message
  
  init(message: Message) {
    self.message = message
  }
  
}
