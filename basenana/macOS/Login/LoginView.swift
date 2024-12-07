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
    
    init() {}
    
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
        
        var clientSet: ClientSet? = nil
        do {
            clientSet = try FSAPI(host: serverHost, port: serverPort, accessTokenKey: accessTokenKey, secretToken: secretToken).login()
            NotificationCenter.default.post(name: NSNotification.Name("login"), object: clientSet)
        } catch {
            errorMessage = "connect server failed: \(error)"
            return
        }
        
        do {
            if let clientSet = clientSet {
                let fi = try await clientSet.fsInfo()
                let info = FSInfo(namespace: fi.namespace, rootID: fi.rootID, inboxID: fi.inboxID)
                NotificationCenter.default.post(name: NSNotification.Name("setFSInfo"), object: info)
            }
        } catch {
            errorMessage = "query fs info failed: \(error)"
            return
        }
    }
}

