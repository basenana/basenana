//
//  NanaFSLoginView.swift
//  basenana
//
//  Created by Hypo on 2024/12/14.
//

import SwiftUI
import Foundation
import AppState
import NetworkExtension


struct NanaFSLoginView: View {
    @State private var store = StateStore.shared
    
    @State private var serverHost:String = ""
    @State private var serverPortStr: String = "7081"
    @State private var accessTokenKey:String = ""
    @State private var secretToken:String = ""
    
    @Binding private var isLogining: Bool
    
    init(isLogining: Binding<Bool>) {
        self._isLogining = isLogining
    }
    
    var body: some View {
        VStack {
            Text("Connect to NanaFS🍌")
                .font(.largeTitle)
                .padding(30)
            Form {
                
                HStack {
                    TextField("Server", text: $serverHost)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isLogining)
                        .padding()
                    
                    TextField("Port", text: $serverPortStr)
                        .textFieldStyle(.roundedBorder)
                        .labelsHidden()
                        .disabled(isLogining)
                        .padding()
                }
                
                TextField("AccessToken", text: $accessTokenKey)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLogining)
                    .padding()
                SecureField("SecretToken", text: $secretToken)
                    .textFieldStyle(.roundedBorder)
                    .disabled(isLogining)
                    .padding()
            }
            
            Button(action: { tryConnect() }) {
                Text(isLogining ? "Connecting" : "Connect" )
                    .font(.body)
                    .padding(10)
                    .frame(width: 220, height: 40)
            }
            .padding(.vertical, 30)
        }
        .onAppear {
            serverHost = store.setting.database.apiHost
            serverPortStr = String(store.setting.database.apiPort)
            accessTokenKey = store.setting.database.apiaccessTokenKey
            secretToken = store.setting.database.apiSecretToken
            defaultLogin()
        }
        .padding(50)
        .frame(minWidth: 700, minHeight: 500)
    }
    
    func tryConnect() {
        isLogining = true
        
        NotificationCenter.default.post(name: .tryLogin, object: LoginRequest(
            serverHost: serverHost,
            serverPort: Int(serverPortStr) ?? -1,
            accessTokenKey: accessTokenKey,
            secretToken: secretToken))
    }
    
    func defaultLogin() {
        guard serverHost != "" else {
            return
        }
        
        guard let _ = Int(serverPortStr) else {
            return
        }
        
        guard accessTokenKey != "" else {
            return
        }
        
        guard secretToken != "" else {
            return
        }
        
        isLogining = true
        
        tryConnect()
    }
    
}

