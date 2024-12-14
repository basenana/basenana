//
//  LoginView.swift
//  basenana
//
//  Created by Hypo on 2024/6/21.
//

import SwiftUI
import Foundation
import AppState
import NetworkExtension


struct LoginView: View {
    @State private var store = StateStore.shared
    @State private var environment = Environment.shared
    
    @State private var isLogining: Bool = false
    @State private var errorMessage = ""
    
    init() {}
    
    var body: some View {
        VStack(alignment: .center) {
            
            NanaFSLoginView(isLogining: $isLogining)
            
            Text("\(errorMessage)")
                .foregroundStyle(.red)
        }
        .onReceive(NotificationCenter.default.publisher(for: .tryLogin)) { [self] notification in
            if let req = notification.object as? LoginRequest {
                self.doLogin(req: req)
            }
        }
        .padding(50)
        .frame(minWidth: 700, minHeight: 500)
    }
    
    func doLogin(req: LoginRequest) {
        Task {
            await handleLogin(serverHost: req.serverHost, serverPort: req.serverPort, accessTokenKey: req.accessTokenKey, secretToken: req.secretToken)
        }
    }
    
    func handleLogin(serverHost: String, serverPort: Int, accessTokenKey: String, secretToken: String) async {
        var clientSet: ClientSet? = nil
        var fsInfo: FSInfo? = nil
        defer { isLogining = false }
        do {
            clientSet = try FSAPI(host: serverHost, port: serverPort, accessTokenKey: accessTokenKey, secretToken: secretToken).login()
        } catch {
            errorMessage = "connect server failed: \(error)"
            return
        }
        
        guard clientSet != nil else {
            errorMessage = "init client failed"
            return
        }
        
        do {
            let fi = try await clientSet!.fsInfo()
            fsInfo = FSInfo(namespace: fi.namespace, rootID: fi.rootID, inboxID: fi.inboxID)
        } catch {
            errorMessage = "query fs info failed: \(error)"
            return
        }
        
        guard fsInfo != nil else {
            errorMessage = "init fsinfo failed"
            return
        }
        
        complateLogin(clientSet: clientSet!, fsInfo: fsInfo!)
        store.setting.database.apiHost = serverHost
        store.setting.database.apiPort = serverPort
        store.setting.database.apiaccessTokenKey = accessTokenKey
        store.setting.database.apiSecretToken = secretToken
    }
    
    @MainActor
    func complateLogin(clientSet: ClientSet, fsInfo: FSInfo) {
        assert(Thread.isMainThread)
        environment.clientSet = clientSet
        store.fsInfo = fsInfo
    }
}


public extension Notification.Name {
    static let tryLogin = Notification.Name(rawValue: "tryLogin")
}


class LoginRequest {
    var serverHost: String
    var serverPort: Int
    var accessTokenKey: String
    var secretToken: String
    
    init(serverHost: String, serverPort: Int, accessTokenKey: String, secretToken: String) {
        self.serverHost = serverHost
        self.serverPort = serverPort
        self.accessTokenKey = accessTokenKey
        self.secretToken = secretToken
    }
}
