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

let clientFactory = ClientFactory()
let clientEventLoopGroup = PlatformSupport.makeEventLoopGroup(loopCount: System.coreCount/2+1)

class ClientFactory {
    
    static let share = ClientFactory()
    
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
    
    private var client: ClientSet? = nil
    
    func makeClient() throws -> ClientSet{
        if self.client == nil {
            try self.login()
        }
        if self.client != nil {
            return self.client!
        }
        throw ClientError.notLogin
    }

    func login() throws {
        log.info("reflush token")
        
        if self.host == ""{
            log.error("[authClient] host is empty")
            throw ClientError.invalidHost
        }
        
        if self.port == 0{
            log.error("[authClient] port is 0")
            throw ClientError.invalidPort
        }
        
        if self.accessTokenKey == "" || self.secretToken == "" {
            log.error("[authClient] accessTokenKey/secretToken is empty")
            throw ClientError.invalidAccessKey
        }
        
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
            let encodedClientCrt = try response.clientCrt.base64Decoded()
            let encodedClientKey = try response.clientKey.base64Decoded()
            self.namespace = response.namespace
            self.client = try ClientSet(host: self.host, port: self.port, clientCrt: encodedClientCrt, clientKey: encodedClientKey, namespace: response.namespace)
        } catch {
            log.error("[authClient] access token with ak \(self.accessTokenKey) failed: \(error)")
            throw ClientError.invalidAccessKey
        }
    }
}

class ClientSet {
    
    var inbox: Api_V1_InboxClientProtocol
    var entries: Api_V1_EntriesClientProtocol
    var properties: Api_V1_PropertiesClientProtocol
    var document: Api_V1_DocumentClientProtocol
    var dialogue: Api_V1_RoomClientProtocol
    var workflow: Api_V1_WorkflowClientProtocol
    var notify: Api_V1_NotifyClientProtocol
    
    private var namespace: String
    
    init(host: String, port: Int, clientCrt: [UInt8], clientKey: [UInt8], namespace: String) throws {
        let tlsChannel = ClientConnection
            .usingTLSBackedByNIOSSL(on: clientEventLoopGroup)
            .withTLS(certificateChain: [try .init(bytes: clientCrt, format: .pem)])
            .withTLS(privateKey: try .init(bytes: clientKey, format: .pem))
            .withTLS(certificateVerification: .none)
            .connect(host: host, port: port)
        
        self.inbox = Api_V1_InboxNIOClient(channel: tlsChannel)
        self.entries = Api_V1_EntriesNIOClient(channel: tlsChannel)
        self.properties = Api_V1_PropertiesNIOClient(channel: tlsChannel)
        self.document = Api_V1_DocumentNIOClient(channel: tlsChannel)
        self.dialogue = Api_V1_RoomNIOClient(channel: tlsChannel)
        self.workflow = Api_V1_WorkflowNIOClient(channel: tlsChannel)
        self.notify = Api_V1_NotifyNIOClient(channel: tlsChannel)
        
        self.namespace = namespace
    }
    
    func fsInfo() throws -> FsInfoModel {
        var result = FsInfoModel()
        result.namespace = namespace
        
        do {
            var req = Api_V1_FindEntryDetailRequest()
            req.root = true
            let resp = try entries.findEntryDetail(req, callOptions: defaultCallOptions).response.wait()
            result.rootID = resp.entry.id
        } catch {
            log.error("refush fs info error, get root entry failed \(error)")
            throw error
        }
        
        do {
            var req = Api_V1_FindEntryDetailRequest()
            req.parentID = result.rootID
            req.name = ".inbox"
            let resp = try entries.findEntryDetail(req, callOptions: defaultCallOptions).response.wait()
            result.inboxID = resp.entry.id
        } catch {
            log.error("refush fs info error, get inbox entry failed \(error)")
            throw error
        }
        
        result.fsApiReady = true
        return result
    }
}


enum ClientError: Error {
    case invalidHost
    case invalidPort
    case invalidAccessKey
    case notLogin
}

let encodingConfiguration = ClientMessageEncoding.Configuration(
    forRequests: .gzip,
    decompressionLimit: .ratio(20)
)


let defaultCallOptions = CallOptions(timeLimit: .timeout(.seconds(10)), messageEncoding: .enabled(encodingConfiguration))
