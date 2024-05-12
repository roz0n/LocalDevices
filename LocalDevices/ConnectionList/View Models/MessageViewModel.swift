//
//  MessageViewModel.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/11/24.
//

import Foundation

final class MessageViewModel: ObservableObject, Identifiable, Hashable {
  
  static func == (lhs: MessageViewModel, rhs: MessageViewModel) -> Bool {
    lhs.id == rhs.id
  }
  
  func hash(into hasher: inout Hasher) {
    hasher.combine(message.data.description)
    hasher.combine(message.timestamp)
  }
  
  private (set) var message: Message
  
  init(message: Message) {
    self.message = message
  }
  
}
