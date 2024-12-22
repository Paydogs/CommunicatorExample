//
//  ClientGrid.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import SwiftUI

struct ClientGrid: View {
    private var clients: [Client]
    
    init(clients: [Client]) {
        self.clients = clients
    }

    var body: some View {
        GeometryReader { geometry in
            let columns = createDynamicColumns(for: geometry.size.width)
                    
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach(clients) { value in
                        ClientView(client: value)
                    }
                }
            }
        }
    }
                            
    // Function to dynamically calculate columns
    func createDynamicColumns(for width: CGFloat) -> [GridItem] {
        let columnCount = max(Int(width / 240), 1) // Minimum column width: 240
        return Array(repeating: GridItem(.flexible()), count: columnCount)
    }
}

#Preview {
    let client = Client(serviceName: "Test")
    ClientGrid(clients: [client])
}

extension Client: Identifiable {}
