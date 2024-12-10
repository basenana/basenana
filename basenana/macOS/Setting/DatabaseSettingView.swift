//
//  DatabaseSettingView.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import AppState


struct DatabaseSettingView: View {
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
            VStack {
                TextField("Host", text: $serverHost)
                TextField("Port", text: $serverPortStr, onCommit: {
                    if let validNumber = Int(serverPortStr) {
                        self.serverPort = validNumber
                    }
                }).onAppear{
                    serverPortStr = "\(self.serverPort)"
                }
                TextField("AccessTokenKey", text: $accessTokenKey)
                TextField("SecretToken", text: $secretToken)
            }
            
            HStack {
                if errorMessage != ""{
                    Text("\(errorMessage)")
                        .foregroundStyle(.red)
                        .padding(.vertical, 5)
                }
                Button {
                    errorMessage = "not support"
                } label: {
                    Text("Disconnect")
                }
                Button {
                    errorMessage = "not check"
                } label: {
                    Text("Verify")
                }
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .formStyle(.grouped)
    }
}

public extension UserDefaults {
    #if DEVELOPMENT
    static let standard = UserDefaults(suiteName: "org.basenana-dev")!
    #endif
}

