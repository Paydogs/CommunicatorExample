//
//  ClientView.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import SwiftUI
import Combine
import Communicator

struct ClientView: View {
    @StateObject private var viewModel: ClientViewModel
    
    init(client: Client) {
        _viewModel =  StateObject(wrappedValue: ClientViewModel(client: client))
    }
    var body: some View {
        VStack {
            Text("\(viewModel.serviceName) Client")
                .font(.largeTitle)
                .padding()
            
            Label("", systemImage: "wave.3.left")
                .scaledToFit()
                .font(.system(size: 24))
                .frame(width: 48, height: 48)
            
            if !viewModel.started {
                Button("Discover and Connect") {
                    viewModel.discoverAndConnect()
                }
                .padding()
            } else {
                Button("Stop") {
                    viewModel.stopClient()
                }
                .padding()
            }
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.log.indices, id: \.self) { index in
                            Text(viewModel.log[index])
                                .textSelection(.enabled)
                                .font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .id(index)
                        }
                    }
                    .onChange(of: viewModel.log) { _ in
                        if let lastIndex = viewModel.log.indices.last {
                            scrollViewProxy.scrollTo(lastIndex, anchor: .bottom)
                        }
                    }
                    .padding()
                }
                .frame(height: 200) // Fixed height for the scrollable area
                .border(Color.gray, width: 1) // Optional border for visibility
                .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
            }
            Button {
                viewModel.clearLog()
            } label: {
                Text("ClearLog")
                    .font(.footnote)
            }
            .padding(.bottom)
            
            TextField("Enter Message", text: $viewModel.messageToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))

            Button("Send to server") {
                viewModel.sendMessage()
            }
            .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
            Button("Send a file to server") {
                browseFile()
            }
            .padding(.init(top: 0, leading: 16, bottom: 8, trailing: 16))

        }
        .frame(minWidth: 240, maxWidth: 240, minHeight: 530, maxHeight: 530)
    }
    
    private func browseFile() {
            let panel = NSOpenPanel()
            panel.canChooseFiles = true
            panel.canChooseDirectories = false
            panel.allowsMultipleSelection = false
            panel.allowedContentTypes = [.data] // Adjust the content types as needed

            if panel.runModal() == .OK {
                guard let url = panel.url else { return }
                do {
                    // Read file content as a string
                    let fileContent = try Data(contentsOf: url)
                    viewModel.sendData(data: fileContent)
                    viewModel.log.append("File \(fileContent.count) bytes sent successfully.")
                } catch {
                    viewModel.log.append("Failed to read file: \(error.localizedDescription)")
                }
            }
        }
}

struct ClientView_Previews: PreviewProvider {
    static var previews: some View {
        ClientView(client: Client(serviceName: "Test"))
        .previewLayout(.sizeThatFits) // Ensures proper sizing in preview
    }
}

class ClientViewModel: ObservableObject {
    @Published var messageToSend: String = ""
    @Published var log: [String] = []
    @Published var started: Bool = false

    var serviceName: String { client.serviceName ?? "UNDEFINED" }
    private var client: Client
    private var cancellable: Set<AnyCancellable> = []
    
    init(client: Client) {
        self.client = client
        client.logMessages.sink { [weak self] message in
            self?.log.append("\(client.currentTimeWithMillis):\n\(message)")
        }
        .store(in: &cancellable)
    }

    func discoverAndConnect() {
        log.append("Discovering...")
        client.discoverAndConnect(serviceName: serviceName)
        started = true
    }
    
    func stopClient() {
        client.stopClient()
        started = false
    }

    func sendMessage() {
        client.sendMessage(messageToSend)
    }
    
    func sendData(data: Data) {
        client.sendData(data)
    }
    
    func clearLog() {
        log.removeAll()
    }
}
