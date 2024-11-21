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
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    private var serverHost:String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    private var serverPort:Int = 0
    @State private var serverPortStr: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    private var accessTokenKey:String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    private var secretToken:String = ""
    
    @State private var errorMessage = ""
    @State private var isLogining = false
    
    private var state: StateStore
    @Binding private var environment: Environment
    
    init(state: StateStore, environment: Binding<Environment>) {
        self.state = state
        self._environment = environment
    }
    
    var body: some View {
        VStack {
            Text("Connect to NanaFS🍌")
                .font(.largeTitle)
                .padding(30)
            Form {
                
                TextField("Server", text: $serverHost)
                    .textFieldStyle(.roundedBorder)
                    .padding()
                
                TextField("Port", text: $serverPortStr, onCommit: {
                    if let validNumber = Int(serverPortStr) {
                        self.serverPort = validNumber
                    }
                }).onAppear{
                    serverPortStr = "\(self.serverPort)"
                }
                .padding()
                .textFieldStyle(.roundedBorder)
                
                TextField("AccessToken", text: $accessTokenKey)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                SecureField("SecretToken", text: $secretToken)
                    .padding()
                    .textFieldStyle(.roundedBorder)
            }
            
            Text("\(errorMessage)")
                .foregroundStyle(.red)
            
            Button(action: {
                Task {
                    await doLogin()
                }
            }) {
                Text(isLogining ? "Connecting" : "Connect" )
                    .font(.body)
                    .padding(10)
                    .frame(width: 220, height: 40)
            }
            .padding(.vertical, 30)
        }
        .padding(50)
        .frame(minWidth: 700, minHeight: 500)
        .task {
            if serverHost != "" && accessTokenKey != "" {
                await doLogin()
            }
        }
    }
    
    func doLogin() async {
        isLogining = true
        defer {
            isLogining = false
        }
        do {
            environment.clientSet = try FSAPI(host: serverHost, port: serverPort, accessTokenKey: accessTokenKey, secretToken: secretToken).login()
        } catch {
            errorMessage = "connect server failed: \(error)"
            return
        }
        do {
            let fsInfo = try environment.clientSet!.fsInfo()
            state.dispatch(.setFsInfo(fsInfo: AppState.FSInfo(namespace: fsInfo.namespace, rootID: fsInfo.rootID, inboxID: fsInfo.inboxID)))
        } catch {
            errorMessage = "query fs info failed: \(error)"
            return
        }
    }
}

