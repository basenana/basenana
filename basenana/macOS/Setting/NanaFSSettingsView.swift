//
//  NanaFSSettingsView.swift
//  basenana
//
//  Created by Hypo on 2024/12/8.
//

import SwiftUI
import Domain
import Data


struct NanaFSSettingsView: View {
    @State private var state = StateStore.shared
    @State private var environment = Environment.shared

    @State private var serverURL: String = ""
    @State private var bearerToken: String = ""
    @State private var errorMessage = ""
    @State private var isUpdating: Bool = false
    @State private var successMessage: String = ""

    private let updateTimeout: TimeInterval = 10

    public var body: some View {
        VStack{
            Form {
                VStack {
                    TextField("Server URL", text: $serverURL)
                    SecureField("BearerToken", text: $bearerToken)
                }

                HStack{
                    Spacer()
                    Button {
                        submit()
                    } label: {
                        if isUpdating {
                            ProgressView()
                                .controlSize(.small)
                            Text(" Verifying...")
                        } else {
                            Text("Verify and Update")
                        }
                    }
                    .buttonStyle(.link)
                    .disabled(isUpdating)
                }

            }
            .formStyle(.grouped)

            if errorMessage != ""{
                Text("\(errorMessage)")
                    .foregroundStyle(.red)
                    .padding(.vertical, 5)
            }

            if successMessage != ""{
                Text("\(successMessage)")
                    .foregroundStyle(.green)
                    .padding(.vertical, 5)
            }
        }
        .navigationTitle(SettingCategory.database.display)
        .onAppear{
            serverURL = state.setting.database.apiURL
            bearerToken = state.setting.database.apiBearerToken
        }
    }

    func submit() {
        guard serverURL.hasPrefix("http://") || serverURL.hasPrefix("https://") else {
            errorMessage = "URL must start with http:// or https://"
            successMessage = ""
            return
        }

        guard bearerToken != "" else {
            errorMessage = "Bearer token cannot be empty"
            successMessage = ""
            return
        }

        isUpdating = true
        errorMessage = ""
        successMessage = ""

        Task {
            await updateSettings(apiURL: serverURL, bearerToken: bearerToken)
        }
    }

    func updateSettings(apiURL: String, bearerToken: String) async {
        var restAPIClient: RestAPIClient?

        do {
            restAPIClient = RestAPIClient(
                apiURL: apiURL,
                token: bearerToken
            )
            restAPIClient!.apiClient.requestTimeout = updateTimeout

            _ = try await withThrowingTaskGroup(of: Data.self) { group in
                group.addTask {
                    try await restAPIClient!.apiClient.requestData(.healthCheck)
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(updateTimeout * 1_000_000_000))
                    throw APIError.timeout
                }
                let result = try await group.next()!
                group.cancelAll()
                return result
            }

        } catch let error as APIError {
            await MainActor.run {
                isUpdating = false
                switch error {
                case .timeout:
                    errorMessage = "Connection timed out. Please check the server address."
                case .unauthorized:
                    errorMessage = "Invalid credentials. Please check your bearer token."
                case .httpError(let statusCode, _):
                    if statusCode == 401 || statusCode == 403 {
                        errorMessage = "Invalid credentials. Please check your bearer token."
                    } else {
                        errorMessage = "Server error (\(statusCode))."
                    }
                case .networkError:
                    errorMessage = "Unable to connect to server. Please check the server address."
                default:
                    errorMessage = "Connection failed: \(error.localizedDescription)"
                }
                successMessage = ""
            }
            return
        } catch {
            await MainActor.run {
                isUpdating = false
                errorMessage = "Connection failed: \(error.localizedDescription)"
                successMessage = ""
            }
            return
        }

        guard let client = restAPIClient else {
            await MainActor.run {
                isUpdating = false
                errorMessage = "Initialization failed."
                successMessage = ""
            }
            return
        }

        await MainActor.run {
            state.setting.database.apiURL = apiURL
            state.setting.database.apiBearerToken = bearerToken
            environment.restAPIClient = client
            state.fsInfo = FSInfo()
            isUpdating = false
            errorMessage = ""
            successMessage = "Settings updated successfully"
        }
    }
}

#if DEVELOPMENT
public extension UserDefaults {
    static let standard = UserDefaults(suiteName: "org.basenana-dev")!
}
#endif
