//
//  NanaFSLoginView.swift
//  basenana
//
//  Created by Hypo on 2024/12/14.
//

import SwiftUI
import Foundation
import Domain
import Data


struct NanaFSLoginView: View {
    @State private var store = StateStore.shared

    @State private var serverURL: String = ""
    @State private var bearerToken: String = ""

    @Binding private var isLogining: Bool

    init(isLogining: Binding<Bool>) {
        self._isLogining = isLogining
    }

    public var body: some View {
        VStack(spacing: 0) {
            Text("🍌")
                .font(.system(size: 70))
                .padding(.top, 20)

            Text("Connect to NanaFS")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .padding(.top, 10)

            VStack(spacing: 20) {
                HStack(spacing: 12) {
                    Image(systemName: "server.rack")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    TextField("Server URL", text: $serverURL)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isLogining)
                }

                HStack(spacing: 12) {
                    Image(systemName: "key.fill")
                        .foregroundStyle(.secondary)
                        .frame(width: 20)

                    SecureField("Bearer Token", text: $bearerToken)
                        .textFieldStyle(.roundedBorder)
                        .disabled(isLogining)
                }
            }
            .padding(.top, 40)
            .padding(.horizontal, 60)

            Button(action: { tryConnect() }) {
                HStack {
                    if isLogining {
                        ProgressView()
                            .controlSize(.small)
                            .padding(.trailing, 8)
                    }
                    Text(isLogining ? "Connecting..." : "Connect")
                }
                .font(.body.weight(.medium))
                .padding(10)
                .frame(width: 220, height: 40)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 40)
            .padding(.bottom, 30)
        }
        .onAppear {
            serverURL = store.setting.database.apiURL
            bearerToken = store.setting.database.apiBearerToken
            defaultLogin()
        }
        .padding(50)
        .frame(minWidth: 700, minHeight: 500)
    }

    func tryConnect() {
        guard serverURL.hasPrefix("http://") || serverURL.hasPrefix("https://") else {
            NotificationCenter.default.post(name: .loginValidationError, object: "URL must start with http:// or https://")
            return
        }

        isLogining = true

        NotificationCenter.default.post(name: .tryLogin, object: LoginRequest(
            apiURL: serverURL,
            bearerToken: bearerToken))
    }

    func defaultLogin() {
        guard serverURL != "" else {
            return
        }

        guard bearerToken != "" else {
            return
        }

        isLogining = true

        tryConnect()
    }

}
