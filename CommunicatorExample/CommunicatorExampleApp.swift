//
//  CommunicatorExampleApp.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import SwiftUI

@main
struct CommunicatorExampleApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var environmentModel = EnvironmentModel()
    
    var body: some Scene {
        WindowGroup("Main Window") {
            MainView(environmentObject: environmentModel)
                .frame(minWidth: 720, maxWidth: 720, minHeight: 200, maxHeight: 200)
        }
        WindowGroup("Servers", id: "servers") {
            ServerGrid(servers: environmentModel.servers)
        }
        .keyboardShortcut("S", modifiers: [.command, .shift])
        WindowGroup("Clients", id: "clients") {
            ClientGrid(clients: environmentModel.clients)
        }
        .keyboardShortcut("C", modifiers: [.command, .shift])
    }
}
