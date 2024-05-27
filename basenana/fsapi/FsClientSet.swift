//
//  FsClient.swift
//  basenana
//
//  Created by Hypo on 2024/4/14.
//

import Foundation
import GRPC
import NIO
import NIOSSL
import SwiftUI


var clientSet: FsClientSet? = nil
let clientEventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: System.coreCount/2+1)

class FsClientSet {
    var inbox: Api_V1_InboxClientProtocol
    var entries: Api_V1_EntriesClientProtocol
    var properties: Api_V1_PropertiesClientProtocol
    var document: Api_V1_DocumentClientProtocol
    var dialogue: Api_V1_RoomClientProtocol
    var workflow: Api_V1_WorkflowClientProtocol
    var notify: Api_V1_NotifyClientProtocol
    
    private var host: String
    private var port: Int
    private var clientCrt: [UInt8]
    private var clientKey: [UInt8]
    
    init(host: String, port: Int, clientCrt: [UInt8], clientKey: [UInt8]) {
        self.host = host
        self.port = port
        
        self.clientCrt = clientCrt
        self.clientKey = clientKey
        
        let tlsChannel = ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateChain: [try! .init(bytes: self.clientCrt, format: .pem)])
            .withTLS(privateKey: try! .init(bytes: self.clientKey, format: .pem))
            .withTLS(certificateVerification: .none)
            .connect(host: self.host, port: self.port)
        
        self.inbox = Api_V1_InboxNIOClient(channel: tlsChannel)
        self.entries = Api_V1_EntriesNIOClient(channel: tlsChannel)
        self.properties = Api_V1_PropertiesNIOClient(channel: tlsChannel)
        self.document = Api_V1_DocumentNIOClient(channel: tlsChannel)
        self.dialogue = Api_V1_RoomNIOClient(channel: tlsChannel)
        self.workflow = Api_V1_WorkflowNIOClient(channel: tlsChannel)
        self.notify = Api_V1_NotifyNIOClient(channel: tlsChannel)
    }
}


class AuthClient {
    @AppStorage("org.basenana.nanafs.host", store: UserDefaults.standard)
    private var host: String = ""
    
    @AppStorage("org.basenana.nanafs.port", store: UserDefaults.standard)
    private var port: Int = 0
    
    @AppStorage("org.basenana.nanafs.clientCrt", store: UserDefaults.standard)
    private var encodedClientCrt: String = ""
    
    @AppStorage("org.basenana.nanafs.clientKey", store: UserDefaults.standard)
    private var encodedClientKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.accessToken", store: UserDefaults.standard)
    private var accessTokenKey: String = ""
    
    @AppStorage("org.basenana.nanafs.auth.secretToken", store: UserDefaults.standard)
    private var secretToken: String = ""
    
    @AppStorage("org.basenana.nanafs.namespace", store: UserDefaults.standard)
    private var namespace: String = ""

    func reflushToken() {
        log.info("reflush token")
        
        if self.host == ""{
            log.error("[authClient] host is empty")
            return
        }
        
        if self.port == 0{
            log.error("[authClient] port is 0")
            return
        }
        
        if self.accessTokenKey == "" || self.secretToken == "" {
            log.error("[authClient] accessTokenKey/secretToken is empty")
            return
        }
        
        if self.encodedClientCrt == "" {
            let authChannel = ClientConnection
                .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
                .withTLS(certificateVerification: .none)
                .connect(host: host, port: port)
            let auth = Api_V1_AuthNIOClient(channel: authChannel)
            
            var request = Api_V1_AccessTokenRequest()
            request.accessTokenKey = self.accessTokenKey
            request.secretToken = self.secretToken
            let call = auth.accessToken(request, callOptions: defaultCallOptions)
            do {
                let response = try call.response.wait()
                self.encodedClientCrt = response.clientCrt
                self.encodedClientKey = response.clientKey
                self.namespace = response.namespace
            } catch {
                log.error("[authClient] access token with ak \(self.accessTokenKey) failed: \(error)")
                return
            }
        }
        
        do {
            clientSet = FsClientSet(host: self.host, port: self.port, clientCrt: try self.encodedClientCrt.base64Decoded(), clientKey: try encodedClientKey.base64Decoded())
            log.info("[authClient] create client set succeed")
            authStatus.hasAccessToken = true
        } catch {
            log.error("[authClient] create client set falied \(error)")
        }
    }
}

@Observable
class AuthStatus {
    public var hasAccessToken: Bool = false
}

let authStatus = AuthStatus()


let encodingConfiguration = ClientMessageEncoding.Configuration(
  forRequests: .gzip,
  decompressionLimit: .ratio(20)
)


let defaultCallOptions = CallOptions(timeLimit: .timeout(.seconds(10)), messageEncoding: .enabled(encodingConfiguration))
