//
//  DatabaseSettingView.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import AppState


struct DatabaseSettingView: View {
    @State private var state = StateStore.shared
    
    @State private var serverHost:String = ""
    @State private var serverPortStr: String = ""
    @State private var accessTokenKey:String = ""
    @State private var secretToken:String = ""
    @State private var errorMessage = ""
    
    var body: some View {
        VStack{
            Form {
                VStack {
                    TextField("Host", text: $serverHost)
                    TextField("Port", text: $serverPortStr)
                    TextField("AccessTokenKey", text: $accessTokenKey)
                    TextField("SecretToken", text: $secretToken)
                }
                
                HStack{
                    Spacer()
                    Button {
                        submit()
                    } label: {
                        Text("Verify and Update")
                    }
                    .buttonStyle(.link)
                }
                
            }
            .formStyle(.grouped)

            if errorMessage != ""{
                Text("\(errorMessage)")
                    .foregroundStyle(.red)
                    .padding(.vertical, 5)
            }
        }
        .navigationTitle(SettingCategory.database.display)
        .onAppear{
            serverHost = state.setting.database.apiHost
            serverPortStr = String(state.setting.database.apiPort)
            accessTokenKey = state.setting.database.apiaccessTokenKey
            secretToken = state.setting.database.apiSecretToken
        }
    }
    
    func submit(){
        errorMessage = "not check"
    }
}

#if DEVELOPMENT
public extension UserDefaults {
    static let standard = UserDefaults(suiteName: "org.basenana-dev")!
}
#endif

