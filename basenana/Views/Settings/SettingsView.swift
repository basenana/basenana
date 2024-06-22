//
//  SettingsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/19.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    private var serverHost:String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    private var serverPort:Int = 0
    @State private var serverPortStr: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    private var accessTokenKey:String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    private var secretToken:String = ""
    
    @AppStorage("org.basenana.nanafs.clientCrt", store: UserDefaults.standard)
    private var encodedClientCrt: String = ""
    
    @AppStorage("org.basenana.sync.sequence", store: UserDefaults.standard)
    private var syncedSeqNum: String = "0"
    
    @State private var errorMessage = ""
    
    var body: some View {
        Form {
            Section("Authentication") {
                TextField("Host", text: $serverHost)
                TextField("Port", text: $serverPortStr, onCommit: {
                    log.debug("parse port \(serverPortStr)")
                    if let validNumber = Int(serverPortStr) {
                        self.serverPort = validNumber
                    }
                }).onAppear{
                    serverPortStr = "\(self.serverPort)"
                }
                TextField("AccessTokenKey", text: $accessTokenKey)
                TextField("SecretToken", text: $secretToken)
            }
            .padding(.horizontal, 50.0)
            .padding(10)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(minWidth: 400, maxWidth: .infinity, minHeight: 20)
            
            HStack {
                if errorMessage != ""{
                    Text("\(errorMessage)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                }
                Button {
                    do {
                        let _ = try clientFactory.login()
                    } catch {
                        errorMessage = "\(error)"
                        return
                    }
                } label: {
                    Text("Submit")
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .formStyle(.grouped)
        .padding(20)
        .frame(maxHeight: .infinity)
    }
}

public extension UserDefaults {
    #if DEVELOPMENT
    static let standard = UserDefaults(suiteName: "org.basenana-dev")!
    #endif
}

