//
//  NanaFSSettingsView.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import Domain


struct NanaFSSettingsView: View {
    @State private var state = StateStore.shared

    @State private var serverURL: String = ""
    @State private var bearerToken: String = ""
    @State private var namespace: String = ""
    @State private var errorMessage = ""

    public var body: some View {
        VStack{
            Form {
                VStack {
                    TextField("Server URL", text: $serverURL)
                    SecureField("BearerToken", text: $bearerToken)
                    TextField("Namespace", text: $namespace)
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
            serverURL = state.setting.database.apiURL
            bearerToken = state.setting.database.apiBearerToken
            namespace = state.setting.database.apiNamespace
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
