//
//  MainView.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import SwiftUI
import Communicator

struct MainView: View {
    @StateObject private var viewModel: MainViewModel
    init(environmentObject: EnvironmentModel) {
        _viewModel = StateObject(wrappedValue: MainViewModel(environmentModel: environmentObject))
    }

    var body: some View {
        VStack {
            Text("Server / Client Tester")
                .font(.largeTitle)
                .padding()
            HStack {
                GroupBox {
                    Text("Add server")
                        .font(.headline)
                    HStack {
                        TextField("Name", text: $viewModel.serverTextField)
                        TextField("Port", text: $viewModel.serverPortField)
                            .onChange(of: viewModel.serverPortField) { newValue in
                                let filtered = newValue.filter { $0.isNumber }

                                if let number = UInt16(filtered) {
                                    viewModel.serverPortField = filtered
                                } else if filtered.isEmpty {
                                    viewModel.serverPortField = ""
                                } else {
                                    viewModel.serverPortField = String(UInt16.max)
                                }
                            }
                    }
                    Button("Add") {
                        viewModel.addServer()
                    }
                }
                .frame(width: 300)
                .padding()
                GroupBox {
                    Text("Add client")
                        .font(.headline)
                    HStack {
                        TextField("Name", text: $viewModel.clientTextField)
                        TextField("Data buffer size (kB)", text: $viewModel.clientDataSizeField)
                            .onChange(of: viewModel.clientDataSizeField) { newValue in
                                let filtered = newValue.filter { $0.isNumber }
                                if let _ = Int(filtered) {
                                    viewModel.clientDataSizeField = filtered
                                } else if filtered.isEmpty {
                                    viewModel.clientDataSizeField = ""
                                } else {
                                    viewModel.clientDataSizeField = String(1024)
                                }
                            }
                    }
                    Button("Add") {
                        viewModel.addclient()
                    }
                }
                .frame(width: 300)
                .padding()
            }
            Spacer()
        }
        .frame(width: 720, height: 200, alignment: .center)
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        let environment = EnvironmentModel()
        MainView(environmentObject: environment)
            .previewLayout(.sizeThatFits) // Ensures proper sizing in preview
    }
}

class MainViewModel: ObservableObject {
    @Published var serverTextField: String = ""
    @Published var serverPortField: String = ""
    @Published var clientTextField: String = ""
    @Published var clientDataSizeField: String = ""
    private var environmentModel: EnvironmentModel
    
    init(environmentModel: EnvironmentModel) {
        self.environmentModel = environmentModel
    }

    func addServer() {
        let port: UInt16 = try! UInt16(serverPortField, format: .number)
        let server = Server(serviceName: serverTextField, port: port)
        environmentModel.servers.insert(server)
        print("adding server: withName \(serverTextField), port \(port)")
        print("Server count: \(environmentModel.servers.count)")
    }
    
    func addclient() {
        let client = Client(serviceName: clientTextField, blockSize: Int(clientDataSizeField).map { $0 * 1024 })
        environmentModel.clients.append(client)
        print("adding client: \(client)")
        print("Client count: \(environmentModel.clients.count)")
    }
}
