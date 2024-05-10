//
//  ConnectionCellView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import SwiftUI

struct ConnectionCellView: View {
  
  var viewModel: ConnectionViewModel
  
  var body: some View {
    VStack(alignment: .leading, spacing: 8) {
      Text(viewModel.name)
        .bold()
      Text(viewModel.port)
        .monospaced()
      Text(viewModel.dnsProtocol.uppercased())
        .bold()
    }
  }
  
}

#Preview {
  let connection = Connection.previewStub
  let viewModel = ConnectionViewModel(connection: connection)
  
  return ConnectionCellView(viewModel: viewModel)
}
