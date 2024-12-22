//
//  Client.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import Combine
import Foundation
import Network

class Client {
    var clientId: UUID = UUID()
    var serviceName: String?
    let logMessage = PassthroughSubject<String, Never>()

    private var connection: NWConnection?

    init(serviceName: String? = nil) {
        self.serviceName = serviceName
    }

    func discoverAndConnect(serviceName: String? = nil, serviceDomain: String = "local.") {
        if let serviceName {
            self.serviceName = serviceName
        }
        guard let service = self.serviceName else { return }
        let type = Constants.serviceTypeFormat(serviceName: service)
        debugLog("Starting to browse for \(type)")
        let browser = NWBrowser(for: .bonjour(type: type, domain: serviceDomain), using: .tcp)

        browser.browseResultsChangedHandler = { [weak self] results, changes in
            for result in results {
                switch result.endpoint {
                case .service(let name, _, _, _):
                    self?.debugLog("Discovered service: \(name)")
                    self?.connect(to: result.endpoint)
                default:
                    break
                }
            }
        }

        browser.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.debugLog("Waiting for server to show up")
            case .failed(let error):
                self?.debugLog("Cannot start finding services: \(error)")
            default:
                break
            }
        }

        browser.start(queue: .main)
    }

    private func connect(to endpoint: NWEndpoint) {
        connection = NWConnection(to: endpoint, using: .tcp)
        connection?.start(queue: .main)

        connection?.stateUpdateHandler = { [weak self] state in
            switch state {
            case .ready:
                self?.debugLog("Connected to server")
                self?.sendMessage("Hello from client!")
            case .failed(let error):
                self?.debugLog("Connection failed: \(error)")
            default:
                break
            }
        }

        connection?.receiveMessage { [weak self] data, context, isComplete, error in
            if let data = data, let message = String(data: data, encoding: .utf8) {
                self?.debugLog("Received message: \(message)")
            }

            if let error = error {
                self?.debugLog("Receive error: \(error)")
            }
        }
    }

    func sendMessage(_ message: String) {
        debugLog("sending message: \(message)")
        if connection?.state == .ready {
            connection?.send(content: message.data(using: .utf8), completion: .contentProcessed { [weak self] error in
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

private extension Client {
    func debugLog(_ message: String) {
        logMessage.send(message)
        print("[Client][\(serviceName ?? "UNDEFINED")]  \(message)")
    }
}

extension Client: Hashable {
    // Conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    // Conform to Equatable
    static func == (lhs: Client, rhs: Client) -> Bool {
        return lhs.id == rhs.id
    }
}
