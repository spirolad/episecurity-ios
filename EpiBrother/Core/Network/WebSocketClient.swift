//
//  WebSocketClient.swift
//  EpiBrother
//
//  Created by Guest User on 23/11/2026.
//

import Foundation
import Combine

public class WebSocketClient: NSObject {
    public static let shared = WebSocketClient()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private var session: URLSession?
    
    public let messageSubject = PassthroughSubject<String, Never>()
    public let connectionState = CurrentValueSubject<Bool, Never>(false)
    
    private var isManuallyDisconnected = false
    
    public override init() {
        super.init()
    }
    
    public func connect(token: String? = nil) {
        disconnect()
        isManuallyDisconnected = false
        
        guard let url = URL(string: AppConfig.webSocketURL) else { return }
        var request = URLRequest(url: url)
        if let token = token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let config = URLSessionConfiguration.default
        session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
        webSocketTask = session?.webSocketTask(with: request)
        webSocketTask?.resume()
        
        listenForMessages()
    }
    
    public func disconnect() {
        isManuallyDisconnected = true
        webSocketTask?.cancel(with: .normalClosure, reason: nil)
        webSocketTask = nil
        connectionState.send(false)
    }
    
    public func send(text: String) {
        let message = URLSessionWebSocketTask.Message.string(text)
        webSocketTask?.send(message) { error in
            if let error = error {
                print("WebSocket send error: \(error.localizedDescription)")
            }
        }
    }
    
    private func listenForMessages() {
        webSocketTask?.receive { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .failure(let error):
                print("WebSocket receive error: \(error.localizedDescription)")
                self.connectionState.send(false)
            case .success(let message):
                switch message {
                case .string(let text):
                    self.messageSubject.send(text)
                case .data(let data):
                    if let text = String(data: data, encoding: .utf8) {
                        self.messageSubject.send(text)
                    }
                @unknown default:
                    break
                }
                if !self.isManuallyDisconnected {
                    self.listenForMessages()
                }
            }
        }
    }
}

extension WebSocketClient: URLSessionWebSocketDelegate {
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didOpenWithProtocol protocol: String?) {
        DispatchQueue.main.async {
            self.connectionState.send(true)
        }
    }
    
    public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
        DispatchQueue.main.async {
            self.connectionState.send(false)
        }
    }
}
