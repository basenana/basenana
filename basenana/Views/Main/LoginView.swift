//
//  LoginView.swift
//  basenana
//
//  Created by Hypo on 2024/6/21.
//

import SwiftUI
import Foundation


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

    @Environment(Store.self) private var store: Store
    
    var body: some View {
        VStack {
            Text("🍌Login")
                .font(.largeTitle)
                .padding(.bottom, 20)
                .padding(.top, 30)

            TextField("NanaFS Server", text: $serverHost)
                .padding()
                .cornerRadius(5.0)
                .padding(.bottom, 10)

            TextField("NanaFS Port", text: $serverPortStr, onCommit: {
                log.debug("parse port \(serverPortStr)")
                if let validNumber = Int(serverPortStr) {
                    self.serverPort = validNumber
                }
            }).onAppear{
                serverPortStr = "\(self.serverPort)"
            }
            .padding()
            .cornerRadius(5.0)
            .padding(.bottom, 10)

            TextField("AccessTokenKey", text: $accessTokenKey)
                .padding()
                .cornerRadius(5.0)
                .padding(.bottom, 10)
            SecureField("SecretToken", text: $secretToken)
                .padding()
                .cornerRadius(5.0)
                .padding(.bottom, 10)
            
            Text("\(errorMessage)")
                .foregroundStyle(.red)
                .padding(.bottom, 10)
            
            Button(action: {
                Task {
                    await doLogin()
                }
            }) {
                Text(isLogining ? "Logining" : "Login" )
                    .foregroundColor(.white)
                    .frame(width: 220, height: 40)
                    .background(Color.blue)
            }
            .cornerRadius(10.0)
            .padding(.bottom, 30)
        }
        .padding()
        .task {
            if serverHost != "" && accessTokenKey != "" {
                await doLogin()
            }
        }
    }
    
    func doLogin() async {
        isLogining = true
        do {
            let _ = try clientFactory.login()
        } catch {
            errorMessage = "\(error)"
            isLogining = false
            return
        }
        await store.dispatch(.login)
    }
}

#Preview {
    LoginView().environment(Store())
}
