//
//  ServerGrid.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import SwiftUI

struct ServerGrid: View {
    private var servers: Set<Server>
    let columns = [GridItem(.flexible()), GridItem(.flexible())]
    
    init(servers: Set<Server>) {
        self.servers = servers
    }
    
    var body: some View {
        GeometryReader { geometry in
            let columns = createDynamicColumns(for: geometry.size.width)
                    
            ScrollView(.vertical) {
                LazyVGrid(columns: columns) {
                    ForEach(servers.sorted(by: {$0.port < $1.port })) { value in
                        ServerView(server: value)
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
    let server = Server(serviceName: "Test", port: 1234)
    ServerGrid(servers: [server])
}

extension Server: Identifiable {}
