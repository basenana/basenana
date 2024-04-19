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


var clientSet: FsClientSet? = nil
let clientEventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: System.coreCount/2+1)

class FsClientSet {
    var inbox: Api_V1_InboxClientProtocol
    var entries: Api_V1_EntriesClientProtocol
    var properties: Api_V1_PropertiesClientProtocol
    var document: Api_V1_DocumentClientProtocol
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
        self.notify = Api_V1_NotifyNIOClient(channel: tlsChannel)
    }
}


class AuthClient {
    private var host: String
    private var port: Int
    private var accessTokenKey: String = ""
    private var secretToken: String = ""
    private var auth: Api_V1_AuthClientProtocol? = nil
    
    init(host: String, port: Int) {
        self.host = host
        self.port = port
    }

    func reflushToken(accessTokenKey: String, secretToken: String) throws {
        log.info("reflush token")
        
        self.accessTokenKey = accessTokenKey
        self.secretToken = secretToken
        
        let authChannel = ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateVerification: .none)
            .connect(host: host, port: port)
        
        self.auth = Api_V1_AuthNIOClient(channel: authChannel)

        var request = Api_V1_AccessTokenRequest()
        request.accessTokenKey = self.accessTokenKey
        request.secretToken = self.secretToken
        let call = self.auth!.accessToken(request, callOptions: CallOptions(timeLimit: .timeout(.seconds(10))))
        
        let response = try call.response.wait()
        let clientCrt = try response.clientCrt.base64Decoded()
        let clientKey = try response.clientKey.base64Decoded()
        
        clientSet = FsClientSet(host: self.host, port: self.port, clientCrt: clientCrt, clientKey: clientKey)
    }
}
