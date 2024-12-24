//
//  EnvironmentModel.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 23..
//

import SwiftUI
import Communicator

class EnvironmentModel: ObservableObject {
    @Published var servers: Set<Server> = []
    @Published var clients: [Client] = []
}
