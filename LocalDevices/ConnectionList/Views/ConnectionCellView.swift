//
//  ConnectionCellView.swift
//  LocalDevices
//
//  Created by Arnaldo Rozon on 5/10/24.
//

import SwiftUI

struct ConnectionCellView: View {
  
  @StateObject var viewModel: ConnectionViewModel
  
  private var dnsChipBackgroundColor: Color {
    viewModel.isConnectionReady ? .blue.opacity(0.25) : Color(UIColor.systemGroupedBackground)
  }
  
  private var dnsChipTextColor: Color {
    viewModel.isConnectionReady ? .blue : Color(UIColor.label).opacity(0.75)
  }
  
  var body: some View {
    HStack(alignment: .center) {
      VStack(alignment: .leading, spacing: 6) {
        Text(viewModel.name)
          .bold()
        HStack(alignment: .center, spacing: 4) {
          Image(systemName: "rectangle.connected.to.line.below")
            .font(.system(size: 10, weight: .bold))
          Text("\(viewModel.port)")
            .font(.system(size: 14, weight: .semibold, design: .monospaced))
        }
        .foregroundColor(.orange)
      }
      Spacer()
      HStack(alignment: .center, spacing: 8) {
        HStack(alignment: .center, spacing: 6) {
          if viewModel.isConnectionReady {
            ProgressView()
              .controlSize(.mini)
              .tint(.blue)
          }
          
          Text(viewModel.dnsProtocol.uppercased())
            .font(.system(size: 14, weight: .semibold))
            .foregroundStyle(dnsChipTextColor)
        }
        .padding(.vertical, 2)
        .padding(.horizontal, 6)
        .background(
          RoundedRectangle(cornerRadius: 8)
            .foregroundStyle(dnsChipBackgroundColor))
        
        Image(systemName: "chevron.right")
          .font(.system(size: 12, weight: .semibold))
          .opacity(0.15)
      }
    }
  }
  
}

#Preview {
  let connection = Connection.previewStub
  let viewModel = ConnectionViewModel(connection: connection)
  
  return ConnectionCellView(viewModel: viewModel)
}
