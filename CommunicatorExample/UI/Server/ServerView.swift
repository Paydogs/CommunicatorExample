//
//  ServerView.swift
//  CommunicatorExample
//
//  Created by Andras Olah on 2024. 12. 22..
//

import SwiftUI
import Combine
import Communicator

struct ServerView: View {
    @StateObject private var viewModel: ServerViewModel

    init(server: Server) {
        _viewModel =  StateObject(wrappedValue: ServerViewModel(server: server))
    }

    var body: some View {
        VStack {
            Text("\(viewModel.serviceName) Server")
                .font(.largeTitle)
            Text("\(viewModel.port)")
                .font(.title2)
            
            Label("", systemImage: "wave.3.left")
                .scaledToFit()
                .font(.system(size: 24))
                .frame(width: 48, height: 48)
            
            Button("Start server") {
                viewModel.startServer()
            }
            .padding()
            
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 8) {
                        ForEach(viewModel.log.indices, id: \.self) { index in
                            Text(viewModel.log[index])
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
                .frame(height: 250) // Fixed height for the scrollable area
                .border(Color.gray, width: 1) // Optional border for visibility
                .padding(.init(top: 0, leading: 16, bottom: 0, trailing: 16))
            }

            Spacer()
            
            TextField("Enter Message", text: $viewModel.messageToSend)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.init(top: 0, leading: 16, bottom: 4, trailing: 16))

            Button("Send message to clients") {
                viewModel.sendMessage()
            }
            .padding(.init(top: 0, leading: 16, bottom: 4, trailing: 16))
            
            Button("Send a file to clients") {
                browseFile()
            }
            .padding(.init(top: 0, leading: 16, bottom: 8, trailing: 16))
        }
        .frame(minWidth: 240, maxWidth: 240, minHeight: 550, maxHeight: 550)
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

struct ServerView_Previews: PreviewProvider {
    static var previews: some View {
        ServerView(server: Server(serviceName: "Test", port: 1234))
        .previewLayout(.sizeThatFits) // Ensures proper sizing in preview
    }
}

class ServerViewModel: ObservableObject {
    @Published var messageToSend: String = ""
    @Published var log: [String] = []

    var serviceName: String { server.serviceName }
    var port: UInt16 { server.port }
    private var server: Server
    private var cancellable: Set<AnyCancellable> = []

    init(server: Server) {
        self.server = server
        server.logMessages.sink { [weak self] message in
            self?.log.append(">> \(message)")
        }
        .store(in: &cancellable)
    }

    func startServer() {
        log.append("Starting server")
        server.startServer()
    }

    func sendMessage() {
        let data = messageToSend.data(using: .utf8)!
        sendData(data: data)
    }
    
    func sendData(data: Data) {
        server.sendData(data)
    }
}
