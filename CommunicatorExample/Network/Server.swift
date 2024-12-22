//
//  Server.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import Combine
import Foundation
import Network

class Server {
    var serverId: UUID = UUID()
    let serviceName: String
    let serviceType: String
    let port: UInt16
    let logMessage = PassthroughSubject<String, Never>()
    
    private var listener: NWListener?
    private var connections: [NWConnection] = []

    init(serviceName: String,port: UInt16) {
        self.serviceName = serviceName
        self.serviceType = Constants.serviceTypeFormat(serviceName: serviceName)
        self.port = port
        
        do {
            listener = try NWListener(using: .tcp, on: NWEndpoint.Port(rawValue: port) ?? .any)
        } catch {
            debugLog("Failed to create listener: \(error)")
        }
    }

    func startServer() {
        listener?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.debugLog("Server ready on port \(self?.listener?.port?.rawValue ?? 0)")
            case .failed(let error):
                self?.debugLog("Listener failed with error: \(error)")
            default:
                break
            }
        }

        listener?.newConnectionHandler = { [weak self] connection in
            self?.debugLog("New connection received")
            self?.handleConnection(connection)
        }

        listener?.start(queue: .main)

        // Publish Bonjour service
        listener?.service = NWListener.Service(name: serviceName, type: serviceType)
    }
    
    func sendMessage(_ message: String) {
        for connection in connections {
            debugLog("sending \(message) through \(connection)")
            
            if connection.state == .ready {
                connection.send(content: message.data(using: .utf8), completion: .contentProcessed { [weak self] error in
                    if let error = error {
                        self?.debugLog("Failed to send message: \(error)")
                    } else {
                        self?.debugLog("Message sent successfully.")
                    }
                })
            } else {
                debugLog("Connection is not ready to send messages.")
            }
        }
    }
}

private extension Server {
    private func handleConnection(_ connection: NWConnection) {
        connection.start(queue: .main)
        connections.append(connection)
        debugLog("Connection count: \(connections.count)")
        
        connection.receiveMessage { data, context, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                self.debugLog("Received message: \(message)")
            }

            if let error = error {
                self.debugLog("Connection error: \(error)")
            }
        }

        let welcomeMessage = "Hello from server!"
        connection.send(content: welcomeMessage.data(using: .utf8), completion: .contentProcessed({ [weak self] error in
            if let error = error {
                self?.debugLog("Failed to send message: \(error)")
            }
        }))
    }
    
    func debugLog(_ message: String) {
        logMessage.send(message)
        print("[Server][\(serviceName)] \(message)")
    }
}

extension Server: Hashable {
    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Conform to Equatable
    static func == (lhs: Server, rhs: Server) -> Bool {
        return lhs.id == rhs.id
    }
}
