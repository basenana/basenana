//
//  Connection.swift
//
//
//  Created by Hypo on 2024/9/15.
//

import Foundation
import Entities
import SwiftUI
import GRPC
import NIO
import NIOSSL

let clientEventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: System.coreCount/2+1)

@available(macOS 11.0, *)
public class Connection {
    static var share = Connection()
    
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    private var host: String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    private var port: Int = 0
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    private var accessTokenKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    private var secretToken: String = ""
    
    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    private var namespace: String = ""
    
    var isLogined: Bool = false
    var clientCrt: [UInt8] = []
    var clientKey: [UInt8] = []
    
    public func login() throws -> GRPCChannel {
        if self.host == ""{
            throw RepositoryError.invalidHost
        }
        
        if self.port == 0{
            throw RepositoryError.invalidPort
        }
        
        if self.accessTokenKey == "" || self.secretToken == "" {
            throw RepositoryError.invalidAccessKey
        }
        
        let authChannel = ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateVerification: .none)
            .connect(host: host, port: port)
        let auth = Api_V1_AuthNIOClient(channel: authChannel)
        
        if !self.isLogined {
            var request = Api_V1_AccessTokenRequest()
            request.accessTokenKey = self.accessTokenKey
            request.secretToken = self.secretToken
            let call = auth.accessToken(request, callOptions: defaultCallOptions)
            do {
                let response = try call.response.wait()
                let encodedClientCrt = try response.clientCrt.base64Decoded()
                let encodedClientKey = try response.clientKey.base64Decoded()
                self.namespace = response.namespace
            } catch {
                throw RepositoryError.loginFailed(error)
            }
        }
        
        self.isLogined = true
        return ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateChain: [try .init(bytes: clientCrt, format: .pem)])
            .withTLS(privateKey: try .init(bytes: clientKey, format: .pem))
            .withTLS(certificateVerification: .none)
            .connect(host: host, port: port)
    }
}
