//
//  SettingsView.swift
//  basenana
//
//  Created by Hypo on 2024/4/19.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("org.basenana.nanafs.host")
    private var serverHost:String = ""
    
    @AppStorage("org.basenana.nanafs.port")
    private var serverPort:Int = 0
    @State private var serverPortStr: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.accessToken")
    private var accessTokenKey:String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken")
    private var secretToken:String = ""
    
    @AppStorage("org.basenana.nanafs.clientCrt")
    private var encodedClientCrt: String = ""
    
    @AppStorage("org.basenana.sync.sequence")
    private var syncedSeqNum: String = "0"
    
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
                Button {
                    encodedClientCrt = ""
                    syncedSeqNum = "0"
                    AuthClient().reflushToken()
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
