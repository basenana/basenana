//
//  LoginView.swift
//  basenana
//
//  REST API login implementation
//

import SwiftUI
import Foundation
import Domain
import Data


struct LoginView: View {
    @State private var store = StateStore.shared
    @State private var environment = Environment.shared

    @State private var isLogining: Bool = false
    @State private var errorMessage = ""

    /// Login timeout in seconds
    private let loginTimeout: TimeInterval = 5

    init() {}

    public var body: some View {
        VStack(alignment: .center) {

            NanaFSLoginView(isLogining: $isLogining)

            Text("\(errorMessage)")
                .foregroundStyle(.red)
        }
        .onReceive(NotificationCenter.default.publisher(for: .tryLogin)) { [self] notification in
            if let req = notification.object as? LoginRequest {
                self.doLogin(req: req)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .loginValidationError)) { [self] notification in
            if let msg = notification.object as? String {
                errorMessage = msg
            }
        }
        .padding(50)
        .frame(minWidth: 700, minHeight: 500)
    }

    func doLogin(req: LoginRequest) {
        Task {
            await handleLogin(apiURL: req.apiURL, bearerToken: req.bearerToken)
        }
    }

    func handleLogin(apiURL: String, bearerToken: String) async {
        isLogining = true
        errorMessage = ""

        var restAPIClient: RestAPIClient? = nil
        var fsInfo: FSInfo? = nil

        do {
            // Create REST API client with short timeout for login check
            restAPIClient = RestAPIClient(
                apiURL: apiURL,
                token: bearerToken
            )

            // Adjust timeout for login
            restAPIClient!.apiClient.requestTimeout = loginTimeout

            // Verify connection by calling health check with timeout
            _ = try await withThrowingTaskGroup(of: Data.self) { group in
                group.addTask {
                    try await restAPIClient!.apiClient.requestData(.healthCheck)
                }
                group.addTask {
                    try await Task.sleep(nanoseconds: UInt64(loginTimeout * 1_000_000_000))
                    throw APIError.timeout
                }
                let result = try await group.next()!
                group.cancelAll()
                return result
            }

            // Reset timeout for full entry request
            restAPIClient!.apiClient.requestTimeout = 30

            // Get fsInfo by querying root entry
            let request = EntryDetailRequest(uri: "/", id: nil)
            let rootResponse: RootEntryResponse = try await restAPIClient!.apiClient.request(
                .entriesDetails(uri: nil, id: nil),
                body: request,
                responseType: RootEntryResponse.self
            )

            fsInfo = FSInfo()

        } catch let error as APIError {
            isLogining = false
            switch error {
            case .timeout:
                errorMessage = "Connection timed out. Please check the server address and try again."
            case .unauthorized:
                errorMessage = "Invalid credentials. Please check your bearer token."
            case .networkError:
                errorMessage = "Unable to connect to server. Please check the server address."
            case .httpError(let statusCode, _):
                if statusCode == 401 || statusCode == 403 {
                    errorMessage = "Invalid credentials. Please check your bearer token."
                } else {
                    errorMessage = "Server error (\(statusCode)). Please try again."
                }
            default:
                errorMessage = "Connection failed: \(error.localizedDescription)"
            }
            return
        } catch {
            isLogining = false
            errorMessage = "Connection failed: \(error.localizedDescription)"
            return
        }

        guard let client = restAPIClient, let info = fsInfo else {
            isLogining = false
            errorMessage = "Initialization failed. Please try again."
            return
        }

        complateLogin(restAPIClient: client, fsInfo: info)
        store.setting.database.apiURL = apiURL
        store.setting.database.apiBearerToken = bearerToken
        isLogining = false
    }

    @MainActor
    func complateLogin(restAPIClient: RestAPIClient, fsInfo: FSInfo) {
        assert(Thread.isMainThread)
        environment.restAPIClient = restAPIClient
        fsInfo.fsApiReady = true
        store.fsInfo = fsInfo
    }
}


public extension Notification.Name {
    static let tryLogin = Notification.Name(rawValue: "tryLogin")
    static let loginValidationError = Notification.Name(rawValue: "loginValidationError")
}


class LoginRequest {
    var apiURL: String
    var bearerToken: String

    init(apiURL: String, bearerToken: String) {
        self.apiURL = apiURL
        self.bearerToken = bearerToken
    }
}

// MARK: - Response Types for Login

struct RootEntryResponse: Decodable {
    let entry: RootEntry
}

struct RootEntry: Decodable {
    let uri: String
    let entry: Int64
    let name: String
    let kind: String
    let is_group: Bool
    let size: Int64
    let version: Int64
    let namespace: String
    let storage: String
    let created_at: Date
    let changed_at: Date
    let modified_at: Date
    let access_at: Date
}
