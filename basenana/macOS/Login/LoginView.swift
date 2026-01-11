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
        .padding(50)
        .frame(minWidth: 700, minHeight: 500)
    }

    func doLogin(req: LoginRequest) {
        Task {
            await handleLogin(serverHost: req.serverHost, serverPort: req.serverPort, bearerToken: req.bearerToken, namespace: req.namespace)
        }
    }

    func handleLogin(serverHost: String, serverPort: Int, bearerToken: String, namespace: String) async {
        isLogining = true
        errorMessage = ""

        var restAPIClient: RestAPIClient? = nil
        var fsInfo: FSInfo? = nil

        do {
            // Create REST API client with short timeout for login check
            restAPIClient = RestAPIClient(
                host: serverHost,
                port: serverPort,
                token: bearerToken,
                namespace: namespace
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
            let rootResponse: RootEntryResponse = try await restAPIClient!.apiClient.request(
                .entriesDetails(uri: "/", id: nil),
                responseType: RootEntryResponse.self
            )

            fsInfo = FSInfo(namespace: namespace)

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
        store.setting.database.apiHost = serverHost
        store.setting.database.apiPort = serverPort
        store.setting.database.apiBearerToken = bearerToken
        store.setting.database.apiNamespace = namespace
        isLogining = false
    }

    @MainActor
    func complateLogin(restAPIClient: RestAPIClient, fsInfo: FSInfo) {
        assert(Thread.isMainThread)
        environment.restAPIClient = restAPIClient
        store.fsInfo = fsInfo
    }
}


public extension Notification.Name {
    static let tryLogin = Notification.Name(rawValue: "tryLogin")
}


class LoginRequest {
    var serverHost: String
    var serverPort: Int
    var bearerToken: String
    var namespace: String

    init(serverHost: String, serverPort: Int, bearerToken: String, namespace: String) {
        self.serverHost = serverHost
        self.serverPort = serverPort
        self.bearerToken = bearerToken
        self.namespace = namespace
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
